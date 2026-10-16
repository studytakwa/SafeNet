const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { RekognitionClient, DetectFacesCommand } = require("@aws-sdk/client-rekognition");

admin.initializeApp();

const awsKey = defineSecret("AWS_ACCESS_KEY_ID");
const awsSecret = defineSecret("AWS_SECRET_ACCESS_KEY");

function calculerAge(date) {
  const now = new Date();
  let age = now.getFullYear() - date.getFullYear();
  const m = now.getMonth() - date.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < date.getDate())) age--;
  return age;
}

exports.verifierAge = onCall(
  { secrets: [awsKey, awsSecret] },
  async (request) => {
    const imageBase64 = request.data.image;
    if (!imageBase64) throw new HttpsError("invalid-argument", "Image manquante");

    let dateNaissanceIso = request.data.dateNaissance;
    let ageDeclare;

    if (dateNaissanceIso) {
      const dob = new Date(dateNaissanceIso);
      ageDeclare = calculerAge(dob);
    } else if (request.auth) {
      const doc = await admin.firestore().collection("utilisateurs").doc(request.auth.uid).get();
      const dob = doc.data()?.dateNaissance?.toDate();
      if (!dob) throw new HttpsError("not-found", "Date de naissance introuvable");
      ageDeclare = calculerAge(dob);
    } else {
      throw new HttpsError("invalid-argument", "Date de naissance manquante");
    }

    // 2. Estimation d'âge par AWS Rekognition (renvoie un intervalle AgeRange { Low, High })
    const client = new RekognitionClient({
      region: "eu-west-1",
      credentials: { accessKeyId: awsKey.value(), secretAccessKey: awsSecret.value() },
    });

    const res = await client.send(new DetectFacesCommand({
      Image: { Bytes: Buffer.from(imageBase64, "base64") },
      Attributes: ["ALL"],
    }));

    if (!res.FaceDetails || res.FaceDetails.length !== 1) {
      throw new HttpsError("failed-precondition", "Un seul visage clair doit être présent sur la photo");
    }

    // Extraction de la fourchette / intervalle d'âge
    const { Low, High } = res.FaceDetails[0].AgeRange;
    const ageEstime = Math.round((Low + High) / 2);

    // 3. Comparaison entre l'âge déclaré et l'intervalle estimé par la caméra (tolérance de ±4 ans)
    const tolerance = 4;
    const compatible = ageDeclare >= (Low - tolerance) && ageDeclare <= (High + tolerance);

    // 4. Si l'utilisateur est authentifié, sauvegarder dans Firestore
    if (request.auth) {
      await admin.firestore().collection("utilisateurs").doc(request.auth.uid).update({
        ageVerifie: compatible,
        intervalleAgeEstime: `${Low} - ${High} ans`,
        verificationAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      compatible: compatible,
      coherent: compatible,
      ageDeclare: ageDeclare,
      ageEstime: ageEstime,
      intervalle: [Low, High],
      low: Low,
      high: High
    };
  }
);
