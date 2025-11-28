import admin from "firebase-admin";

export const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Missing or invalid Token" });
    }

    const token = authHeader.split(" ")[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        console.log("Decoded Token:", decodedToken);

        const uid = decodedToken.uid;

        const userDoc = await admin.firestore().collection("users").doc(uid).get();

        if (userDoc.exists) {
            const userData = userDoc.data();

            req.user = {
                ...decodedToken,
                username: userData.userName || null,
                displayName: userData.displayName || null,
                role: userData.role || "user",
            };
        } else {
            req.user = decodedToken;
        }

        next();
    } catch(error) {
        console.error("Error verifying token:", error);
        return res.status(401).json({ error: "Unauthorized" });
    }
};
