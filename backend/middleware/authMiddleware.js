import admin from "firebase-admin";

export const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Mising or invalid Token" });
    }
    

    const token = authHeader.split(" ")[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        console.log("Decoded Token:", decodedToken);

        req.user = decodedToken;
        next();
    }
    catch(error) {
        console.error("Error verifying token:", error);
        return res.status(401).json({ error: "Unauthorized" });
    }

}