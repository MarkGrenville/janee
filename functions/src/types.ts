import { Timestamp } from "firebase-admin/firestore";

// --- Response types ---

export type ResponseType = "yes_no" | "multiple_choice" | "free_text";
export type DecisionValue = "yes" | "no" | "skip";
export type FriendStatus = "pending" | "accepted" | "blocked";
export type CardStatus = "active" | "archived";

// --- Firestore document interfaces ---

export interface UserDoc {
  displayName: string;
  email: string;
  photoURL: string;
  publicProfile: boolean;
  bio: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AppDoc {
  name: string;
  description: string;
  icon: string;
  imageUrl: string;
  coverColor: string;
  ownerId: string;
  isPublic: boolean;
  responseType: ResponseType;
  webhookUrl: string;
  subscriberCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface CardDoc {
  title: string;
  subtitle: string;
  description: string;
  imageUrl: string;
  linkUrl: string;
  icon: string;
  status: CardStatus;
  webhookUrl: string;
  metadata: Record<string, unknown>;
  createdAt: Timestamp;
  availableSince: Timestamp;
  createdBy: string;
}

export interface DecisionDoc {
  appId: string;
  cardId: string;
  cardTitle: string;
  decision: DecisionValue;
  decidedAt: Timestamp;
  availableSince: Timestamp;
  timeToDecisionMs: number;
  webhookFired: boolean;
  webhookResponse: Record<string, unknown> | null;
  webhookFiredAt: Timestamp | null;
}

export interface SubscriptionDoc {
  subscribedAt: Timestamp;
  notifications: boolean;
}

export interface FriendDoc {
  status: FriendStatus;
  initiatedBy: string;
  since: Timestamp;
}

export interface ApiKeyDoc {
  userId: string;
  appId: string;
  label: string;
  keyPrefix: string;
  permissions: string[];
  createdAt: Timestamp;
  lastUsedAt: Timestamp | null;
}

// --- API request/response shapes ---

export interface CreateAppRequest {
  name: string;
  description?: string;
  icon?: string;
  imageUrl?: string;
  coverColor?: string;
  isPublic?: boolean;
  responseType?: ResponseType;
  webhookUrl?: string;
}

export interface CreateCardRequest {
  title: string;
  subtitle?: string;
  description?: string;
  imageUrl?: string;
  linkUrl?: string;
  icon?: string;
  webhookUrl?: string;
  metadata?: Record<string, unknown>;
}

export interface CreateDecisionRequest {
  cardId: string;
  decision: DecisionValue;
}

export interface CreateApiKeyRequest {
  appId: string;
  label?: string;
  permissions?: string[];
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}
