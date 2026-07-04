import { initializeApp, getApps, type FirebaseApp } from 'firebase/app';
import { getAuth, connectAuthEmulator, type Auth } from 'firebase/auth';
import { getFirestore, connectFirestoreEmulator, type Firestore } from 'firebase/firestore';
import { getStorage, connectStorageEmulator, type FirebaseStorage } from 'firebase/storage';
import { getFunctions, connectFunctionsEmulator, type Functions } from 'firebase/functions';

const firebaseConfig = {
	apiKey: 'demo-janee-key',
	authDomain: 'demo-janee.firebaseapp.com',
	projectId: 'demo-janee',
	storageBucket: 'demo-janee.appspot.com',
	messagingSenderId: '000000000000',
	appId: '1:000000000000:web:000000000000',
};

let app: FirebaseApp;
let auth: Auth;
let db: Firestore;
let storage: FirebaseStorage;
let functions: Functions;

function initialize() {
	if (getApps().length > 0) return;

	app = initializeApp(firebaseConfig);
	auth = getAuth(app);
	db = getFirestore(app);
	storage = getStorage(app);
	functions = getFunctions(app);

	if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
		console.log('[firebase] Connecting to emulators...');
		connectAuthEmulator(auth, 'http://localhost:6411', { disableWarnings: true });
		connectFirestoreEmulator(db, 'localhost', 6412);
		connectStorageEmulator(storage, 'localhost', 6415);
		connectFunctionsEmulator(functions, 'localhost', 6413);
		console.log('[firebase] Emulators connected');
	}
}

export function getFirebaseApp(): FirebaseApp {
	initialize();
	return app;
}

export function getFirebaseAuth(): Auth {
	initialize();
	return auth;
}

export function getFirebaseDb(): Firestore {
	initialize();
	return db;
}

export function getFirebaseStorage(): FirebaseStorage {
	initialize();
	return storage;
}

export function getFirebaseFunctions(): Functions {
	initialize();
	return functions;
}
