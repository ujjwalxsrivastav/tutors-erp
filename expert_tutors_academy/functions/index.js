const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 1. onLeadCreated
 * Triggers when a new parent enquiry is submitted.
 * - Ensures sequential ETA lead number
 * - Automatically computes top tutor matches
 * - Sends in-app and FCM notifications to agents
 */
exports.onLeadCreated = functions.firestore
  .document("leads/{leadId}")
  .onCreate(async (snap, context) => {
    const leadId = context.params.leadId;
    const lead = snap.data();

    // 1. Assign sequential number if not already set
    let leadNumber = lead.leadNumber;
    if (!leadNumber || leadNumber.startsWith("TEMP-") || leadNumber === "") {
      const year = new Date().getFullYear();
      const counterRef = db.collection("settings").doc("leadSequence");

      leadNumber = await db.runTransaction(async (t) => {
        const doc = await t.get(counterRef);
        let seq = 1;
        let cYear = year;
        if (doc.exists) {
          const d = doc.data();
          cYear = d.currentYear || year;
          seq = (d.currentSequence || 0) + 1;
          if (cYear !== year) {
            seq = 1;
            cYear = year;
          }
        }
        t.set(counterRef, { currentYear: cYear, currentSequence: seq }, { merge: true });
        return `ETA-${cYear}-${String(seq).padStart(5, "0")}`;
      });

      await snap.ref.update({ leadNumber: leadNumber, status: "MATCHING" });
    }

    // 2. Perform quick matching against verified tutors
    try {
      const tutorsSnap = await db
        .collection("tutors")
        .where("verificationStatus", "==", "VERIFIED")
        .get();

      let bestScore = 0;
      let matchCount = 0;

      tutorsSnap.forEach((doc) => {
        const tutor = doc.data();
        let score = 0;

        // Subject match
        const leadSubjects = lead.subjects || [];
        const tutorSubjects = tutor.subjects || [];
        const hasSubject = leadSubjects.some((s) =>
          tutorSubjects.map((ts) => ts.toLowerCase()).includes(s.toLowerCase())
        );
        if (hasSubject) score += 35;

        // Class match
        const leadClass = lead.studentClass || "";
        const tutorClasses = tutor.classesTaught || [];
        if (tutorClasses.includes(leadClass)) score += 25;

        // Location match
        const leadArea = (lead.location?.area || "").toLowerCase();
        const preferredLocs = (tutor.preferredLocations || []).map((l) => l.toLowerCase());
        if (preferredLocs.includes(leadArea)) {
          score += 25;
        } else if (preferredLocs.some((l) => l.includes(leadArea) || leadArea.includes(l))) {
          score += 15;
        }

        // Mode match
        if (tutor.teachingMode === "BOTH" || tutor.teachingMode === lead.preferredMode) {
          score += 15;
        }

        if (score >= 40) {
          matchCount++;
          if (score > bestScore) bestScore = score;
        }
      });

      await snap.ref.update({
        status: matchCount > 0 ? "MATCHED" : "NEW",
        matchCount: matchCount,
        bestMatchScore: bestScore,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      console.error("Matching error:", err);
    }

    // 3. Notify all admin & agents
    try {
      const usersSnap = await db
        .collection("users")
        .where("role", "in", ["SUPER_ADMIN", "AGENT"])
        .get();

      const batch = db.batch();
      usersSnap.forEach((userDoc) => {
        const notifRef = db.collection("notifications").doc();
        batch.set(notifRef, {
          userId: userDoc.id,
          title: `New Lead: ${leadNumber}`,
          body: `Requirement for Class ${lead.studentClass} (${(lead.subjects || []).join(", ")}) in ${lead.location?.area || ""}`,
          type: "NEW_LEAD",
          data: { leadId: leadId, leadNumber: leadNumber },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
      await batch.commit();

      // Send FCM to topic
      await admin.messaging().send({
        topic: "admin_leads",
        notification: {
          title: `New Lead ${leadNumber}`,
          body: `${lead.studentName} — Class ${lead.studentClass}`,
        },
        data: { leadId: leadId },
      });
    } catch (err) {
      console.error("Notification error:", err);
    }
  });

/**
 * 2. onAssignmentUpdated
 * Triggers when tutor accepts/declines assignment.
 */
exports.onAssignmentUpdated = functions.firestore
  .document("leadAssignments/{assignmentId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return null;

    const leadRef = db.collection("leads").doc(after.leadId);

    if (after.status === "ACCEPTED") {
      await leadRef.update({
        status: "ASSIGNED",
        assignedTutorId: after.tutorId,
        assignedTutorName: after.tutorName,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Notify agency
      await db.collection("notifications").add({
        userId: after.assignedBy,
        title: "Assignment Accepted",
        body: `${after.tutorName} accepted lead ${after.leadNumber}`,
        type: "ASSIGNMENT_ACCEPTED",
        data: { assignmentId: context.params.assignmentId, leadId: after.leadId },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else if (after.status === "REJECTED") {
      await leadRef.update({
        status: "MATCHED",
        assignedTutorId: null,
        assignedTutorName: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Notify agency to reassign
      await db.collection("notifications").add({
        userId: after.assignedBy,
        title: "Assignment Declined",
        body: `${after.tutorName} declined lead ${after.leadNumber}. Reason: ${after.tutorResponse || "None"}`,
        type: "ASSIGNMENT_REJECTED",
        data: { assignmentId: context.params.assignmentId, leadId: after.leadId },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return null;
  });

/**
 * 3. onTuitionCreated
 * Triggers when lead is converted to active tuition.
 */
exports.onTuitionCreated = functions.firestore
  .document("tuitions/{tuitionId}")
  .onCreate(async (snap, context) => {
    const tuition = snap.data();

    // 1. Mark lead as CONVERTED
    await db.collection("leads").doc(tuition.leadId).update({
      status: "CONVERTED",
      convertedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. Increment tutor activeTuitions
    const tutorRef = db.collection("tutors").doc(tuition.tutorId);
    await tutorRef.update({
      "performance.activeTuitions": admin.firestore.FieldValue.increment(1),
      "performance.convertedLeads": admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Schedule first week follow-up
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 7);

    await db.collection("followUps").add({
      entityType: "TUITION",
      entityId: context.params.tuitionId,
      entityNumber: tuition.leadNumber,
      assignedTo: "agent",
      assignedToName: "Agency Agent",
      dueDate: admin.firestore.Timestamp.fromDate(dueDate),
      type: "First Week Feedback",
      notes: `Call parent (${tuition.parentName} - ${tuition.parentPhone}) for 1-week tuition feedback with ${tuition.tutorName}.`,
      status: "PENDING",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
