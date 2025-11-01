/**
 * CroplyAI Firebase Function — Image Analysis via Roboflow
 */

import express, { Request } from "express";
import multer from "multer";
import fetch from "node-fetch";
import fs from "fs";
import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";
import * as logger from "firebase-functions/logger";
import cors from "cors";

// Limit concurrent instances
setGlobalOptions({ maxInstances: 10 });

// Initialize Express
const app = express();
app.use(cors()); // ✅ Allow Flutter frontend requests

// Configure Multer to save uploaded files inside /tmp (Cloud Functions' temp folder)
const upload = multer({ dest: "/tmp" });

// Roboflow credentials and endpoints
const API_KEY = "f25wkYvbi6pVeecAtE2m"; // ⚠ Replace with your actual Roboflow key
const WORKSPACE = "croply-ai";
const WORKFLOW = "croply-ai-final-2";
const ROBOFLOW_URL = `https://serverless.roboflow.com/${WORKSPACE}/workflows/${WORKFLOW}`;

// ✅ Image analysis route
app.post("/analyze", upload.single("image"), async (req: Request, res) => {
  try {
    const file = (req as any).file;

    if (!file) {
      return res.status(400).json({ success: false, error: "No image uploaded." });
    }

    // Read stream for file upload
    const filePath = file.path;
    const fileStream = fs.createReadStream(filePath);

    logger.info("📤 Uploading image to Roboflow...");

    // Send image to Roboflow Workflow
    const response = await fetch(ROBOFLOW_URL, {
      method: "POST",
      headers: {
        Authorization: API_KEY,
        "Content-Type": "application/octet-stream",
      },
      body: fileStream,
    });

    if (!response.ok) {
      const errorText = await response.text();
      logger.error(`❌ Roboflow API Error: ${response.status} — ${errorText}`);
      throw new Error(`Roboflow request failed: ${response.status}`);
    }

    // Parse JSON response
    const data = await response.json();
    fs.unlinkSync(filePath); // Cleanup temp file

    logger.info("✅ Roboflow response received:", data);

    // Return normalized structure to Flutter app
    return res.status(200).json({
      success: true,
      result: {
        output_detected_disease: data.output_detected_disease || data.disease || "Unknown Disease",
        output_treatment_recommendation: data.output_treatment_recommendation || data.recommendation || "No recommendation available.",
        full_response: data,
      },
    });
  } catch (err: any) {
    logger.error("❌ Image analysis error:", err);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error — check function logs.",
      error: err.message,
    });
  }
});

// Export HTTPS trigger for Firebase hosting
export const api = onRequest(app);
