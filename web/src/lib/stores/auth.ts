import { writable, derived } from 'svelte/store';
import { onAuthStateChanged, signInWithEmailAndPassword, createUserWithEmailAndPassword, signInWithPopup, GoogleAuthProvider, signOut as firebaseSignOut, type User } from 'firebase/auth';
import { getFirebaseAuth } from '$lib/firebase/config';

export const user = writable<User | null>(null);
export const loading = writable(true);
export const isAuthenticated = derived(user, ($user) => $user !== null);

let initialized = false;

export function initAuth() {
	if (initialized) return;
	initialized = true;

	const auth = getFirebaseAuth();
	onAuthStateChanged(auth, (firebaseUser) => {
		console.log('[auth] State changed:', firebaseUser?.email || 'signed out');
		user.set(firebaseUser);
		loading.set(false);
	});
}

export async function signInWithEmail(email: string, password: string) {
	const auth = getFirebaseAuth();
	console.log('[auth] Signing in with email:', email);
	return signInWithEmailAndPassword(auth, email, password);
}

export async function registerWithEmail(email: string, password: string) {
	const auth = getFirebaseAuth();
	console.log('[auth] Registering with email:', email);
	return createUserWithEmailAndPassword(auth, email, password);
}

export async function signInWithGoogle() {
	const auth = getFirebaseAuth();
	const provider = new GoogleAuthProvider();
	console.log('[auth] Signing in with Google');
	return signInWithPopup(auth, provider);
}

export async function signOut() {
	const auth = getFirebaseAuth();
	console.log('[auth] Signing out');
	return firebaseSignOut(auth);
}
