const https = require('https');

function post(url, data, headers = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname,
      path: u.pathname + u.search,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...headers }
    }, res => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, body });
        }
      });
    });
    req.on('error', reject);
    req.write(JSON.stringify(data));
    req.end();
  });
}

function patch(url, data, headers = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname,
      path: u.pathname + u.search,
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', ...headers }
    }, res => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, body });
        }
      });
    });
    req.on('error', reject);
    req.write(JSON.stringify(data));
    req.end();
  });
}

async function signUpOrLogin(apiKey, email, password) {
  let res = await post(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`, {
    email,
    password,
    returnSecureToken: true
  });
  if (res.status === 200) {
    return res.data;
  }
  // Try signup
  res = await post(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`, {
    email,
    password,
    returnSecureToken: true
  });
  if (res.status === 200) {
    return res.data;
  }
  throw new Error(`Auth failed for ${email}: ` + JSON.stringify(res));
}

async function main() {
  const apiKey = 'AIzaSyBll4WKmjb0BG0kaZCexJN4hZo0TAGj_IU';
  const projectId = 'tutor6841-eba34';

  console.log('1. Signing in/creating Super Admin...');
  const adminAuth = await signUpOrLogin(apiKey, 'admin@experttutors.com', 'AdminPassword@123');
  console.log('Admin UID:', adminAuth.localId);

  // 2. Write admin user doc
  console.log('2. Writing admin user document to Firestore...');
  const adminDocUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${adminAuth.localId}`;
  const adminDocRes = await patch(adminDocUrl, {
    fields: {
      name: { stringValue: 'Super Admin' },
      email: { stringValue: 'admin@experttutors.com' },
      phone: { stringValue: '+919876543210' },
      role: { stringValue: 'SUPER_ADMIN' },
      isActive: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
      updatedAt: { timestampValue: new Date().toISOString() }
    }
  }, {
    'Authorization': 'Bearer ' + adminAuth.idToken
  });
  console.log('Admin doc write result:', adminDocRes.status, adminDocRes.data ? 'Success' : adminDocRes.body);

  // 3. Create a Demo Tutor user
  console.log('3. Creating Demo Tutor account...');
  const tutorAuth = await signUpOrLogin(apiKey, 'tutor@experttutors.com', 'TutorPassword@123');
  console.log('Tutor UID:', tutorAuth.localId);

  // Write tutor user doc
  const tutorDocUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${tutorAuth.localId}`;
  await patch(tutorDocUrl, {
    fields: {
      name: { stringValue: 'Rahul Sharma' },
      email: { stringValue: 'tutor@experttutors.com' },
      phone: { stringValue: '+919812345678' },
      role: { stringValue: 'TUTOR' },
      isActive: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
      updatedAt: { timestampValue: new Date().toISOString() }
    }
  }, {
    'Authorization': 'Bearer ' + adminAuth.idToken
  });
  console.log('Tutor user doc created.');

  // Write tutor profile in tutors collection
  const tutorProfileUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/tutors/${tutorAuth.localId}`;
  await patch(tutorProfileUrl, {
    fields: {
      name: { stringValue: 'Rahul Sharma' },
      email: { stringValue: 'tutor@experttutors.com' },
      phone: { stringValue: '+919812345678' },
      highestQualification: { stringValue: 'M.Sc. Mathematics' },
      experienceYears: { integerValue: '5' },
      status: { stringValue: 'ACTIVE' },
      subjects: { arrayValue: { values: [{ stringValue: 'Mathematics' }, { stringValue: 'Physics' }] } },
      classesTeaching: { arrayValue: { values: [{ stringValue: 'Class 9' }, { stringValue: 'Class 10' }, { stringValue: 'Class 11' }, { stringValue: 'Class 12' }] } },
      preferredBoards: { arrayValue: { values: [{ stringValue: 'CBSE' }, { stringValue: 'ICSE' }] } },
      areasCovered: { arrayValue: { values: [{ stringValue: 'Indira Nagar' }, { stringValue: 'Gomti Nagar' }, { stringValue: 'Aliganj' }] } },
      rating: { doubleValue: 4.8 },
      totalTuitionsTaken: { integerValue: '18' },
      conversionRate: { doubleValue: 88.5 },
      createdAt: { timestampValue: new Date().toISOString() },
      updatedAt: { timestampValue: new Date().toISOString() }
    }
  }, {
    'Authorization': 'Bearer ' + adminAuth.idToken
  });
  console.log('Tutor profile in tutors/ collection created.');

  // 4. Initialize leadSequence in settings
  console.log('4. Initializing settings/leadSequence...');
  const seqUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/settings/leadSequence`;
  await patch(seqUrl, {
    fields: {
      currentYear: { integerValue: String(new Date().getFullYear()) },
      currentSequence: { integerValue: '0' }
    }
  }, {
    'Authorization': 'Bearer ' + adminAuth.idToken
  });
  console.log('Settings/leadSequence initialized.');

  // 5. Seed a sample Lead
  console.log('5. Creating a sample Lead...');
  const sampleLeadUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/leads/sample_lead_01`;
  await patch(sampleLeadUrl, {
    fields: {
      leadNumber: { stringValue: `ETA-${new Date().getFullYear()}-00001` },
      parentName: { stringValue: 'Sunita Verma' },
      studentName: { stringValue: 'Aarav Verma' },
      phone: { stringValue: '+919988776655' },
      email: { stringValue: 'sunita.verma@example.com' },
      grade: { stringValue: 'Class 10' },
      board: { stringValue: 'CBSE' },
      subjects: { arrayValue: { values: [{ stringValue: 'Mathematics' }, { stringValue: 'Science' }] } },
      address: { stringValue: 'Sector B, Indira Nagar, Lucknow' },
      locality: { stringValue: 'Indira Nagar' },
      preferredGender: { stringValue: 'ANY' },
      budgetMin: { integerValue: '4000' },
      budgetMax: { integerValue: '6000' },
      mode: { stringValue: 'OFFLINE_HOME' },
      status: { stringValue: 'IN_MATCHING' },
      stage: { stringValue: 'MATCHING' },
      enquiryDate: { timestampValue: new Date().toISOString() },
      createdAt: { timestampValue: new Date().toISOString() },
      updatedAt: { timestampValue: new Date().toISOString() }
    }
  }, {
    'Authorization': 'Bearer ' + adminAuth.idToken
  });
  console.log('Sample lead created.');

  console.log('\n=========================================');
  console.log('ALL SEEDING COMPLETED SUCCESSFULLY!');
  console.log('Admin Email:    admin@experttutors.com');
  console.log('Admin Password: AdminPassword@123');
  console.log('Tutor Email:    tutor@experttutors.com');
  console.log('Tutor Password: TutorPassword@123');
  console.log('=========================================');
}

main().catch(err => {
  console.error('Seeding error:', err);
  process.exit(1);
});
