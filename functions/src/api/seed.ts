import { Router } from "express";
import * as admin from "firebase-admin";

const router = Router();
const getDb = () => admin.firestore();

router.post("/", async (_req, res) => {
  try {
    console.log("[seed] Starting database seed...");
    const now = admin.firestore.Timestamp.now();

    const demoUser = {
      displayName: "Demo User",
      email: "demo@janee.app",
      photoURL: "",
      publicProfile: true,
      bio: "Just swiping through life, one decision at a time.",
      createdAt: now,
      updatedAt: now,
    };
    await getDb().collection("users").doc("demo-user").set(demoUser);
    console.log("[seed] Created demo user");

    const apps = [
      {
        name: "Movie Watchlist",
        description: "Swipe through new releases and build your watchlist. Yes = want to watch, No = not interested.",
        icon: "🎬",
        imageUrl: "",
        coverColor: "#1a1a2e",
        ownerId: "demo-user",
        isPublic: true,
        responseType: "yes_no" as const,
        webhookUrl: "",
        subscriberCount: 142,
        createdAt: now,
        updatedAt: now,
      },
      {
        name: "Date Night Ideas",
        description: "Couples swipe together to find activities you both love. Share the link with your partner!",
        icon: "💕",
        imageUrl: "",
        coverColor: "#C4908A",
        ownerId: "demo-user",
        isPublic: true,
        responseType: "yes_no" as const,
        webhookUrl: "",
        subscriberCount: 89,
        createdAt: now,
        updatedAt: now,
      },
      {
        name: "Boss Approvals",
        description: "Quick decisions that need the boss's sign-off. Yes = approved, No = rejected, Skip = need more info.",
        icon: "✅",
        imageUrl: "",
        coverColor: "#2d6a4f",
        ownerId: "demo-user",
        isPublic: false,
        responseType: "yes_no" as const,
        webhookUrl: "https://hooks.example.com/approvals",
        subscriberCount: 3,
        createdAt: now,
        updatedAt: now,
      },
    ];

    const appIds: string[] = [];
    for (const app of apps) {
      const ref = await getDb().collection("apps").add(app);
      appIds.push(ref.id);
      console.log(`[seed] Created app: ${app.name} (${ref.id})`);
    }

    const movieCards = [
      { title: "Dune: Part Three", subtitle: "2026 Sci-Fi Epic", description: "The final chapter of the Dune saga.", icon: "🏜️" },
      { title: "Spider-Man: Brand New Day", subtitle: "2026 Marvel", description: "Peter Parker faces a multiverse threat.", icon: "🕷️" },
      { title: "The Batman Part II", subtitle: "2026 DC", description: "The Dark Knight returns to Gotham.", icon: "🦇" },
      { title: "Avatar 3", subtitle: "2025 Sci-Fi", description: "Return to Pandora — fire and ash.", icon: "🌋" },
      { title: "Wicked: For Good", subtitle: "2025 Musical", description: "The conclusion to the Wicked story.", icon: "🧙‍♀️" },
    ];

    for (const card of movieCards) {
      await getDb().collection("apps").doc(appIds[0]).collection("cards").add({
        ...card,
        linkUrl: "",
        imageUrl: "",
        status: "active",
        webhookUrl: "",
        metadata: {},
        createdAt: now,
        availableSince: now,
        createdBy: "demo-user",
      });
    }
    console.log(`[seed] Added ${movieCards.length} movie cards`);

    const dateCards = [
      { title: "Sunset Picnic", subtitle: "Outdoor", description: "Pack a basket and watch the sunset together.", icon: "🌅" },
      { title: "Cooking Class", subtitle: "Activity", description: "Learn to make pasta from scratch.", icon: "👨‍🍳" },
      { title: "Escape Room", subtitle: "Adventure", description: "Can you solve the puzzles in time?", icon: "🔐" },
      { title: "Jazz Night", subtitle: "Music", description: "Live jazz at a cozy downtown bar.", icon: "🎷" },
    ];

    for (const card of dateCards) {
      await getDb().collection("apps").doc(appIds[1]).collection("cards").add({
        ...card,
        linkUrl: "",
        imageUrl: "",
        status: "active",
        webhookUrl: "",
        metadata: {},
        createdAt: now,
        availableSince: now,
        createdBy: "demo-user",
      });
    }
    console.log(`[seed] Added ${dateCards.length} date night cards`);

    const approvalCards = [
      {
        title: "Hire Sarah Chen — Senior Dev",
        subtitle: "Engineering",
        description: "Strong references, 8 years experience, passed all rounds. Offer: $145k + equity.",
        icon: "👤",
        metadata: { department: "Engineering", salary: 145000, urgency: "high" },
      },
      {
        title: "Activate Project Phoenix",
        subtitle: "Operations",
        description: "Q3 initiative — estimated budget $50k, 3 month timeline. All stakeholders aligned.",
        icon: "🚀",
        metadata: { budget: 50000, timeline: "3 months" },
      },
    ];

    for (const card of approvalCards) {
      await getDb().collection("apps").doc(appIds[2]).collection("cards").add({
        title: card.title,
        subtitle: card.subtitle,
        description: card.description,
        icon: card.icon,
        linkUrl: "",
        imageUrl: "",
        status: "active",
        webhookUrl: "",
        metadata: card.metadata,
        createdAt: now,
        availableSince: now,
        createdBy: "demo-user",
      });
    }
    console.log(`[seed] Added ${approvalCards.length} approval cards`);

    for (const appId of appIds) {
      await getDb().collection("users").doc("demo-user").collection("subscriptions").doc(appId).set({
        subscribedAt: now,
        notifications: true,
      });
    }

    console.log("[seed] Database seeded successfully");
    res.json({
      success: true,
      data: {
        userId: "demo-user",
        apps: appIds.map((id, i) => ({ id, name: apps[i].name })),
      },
    });
  } catch (err) {
    console.log("[seed] Error seeding:", err);
    res.status(500).json({ success: false, error: "Failed to seed database" });
  }
});

export default router;
