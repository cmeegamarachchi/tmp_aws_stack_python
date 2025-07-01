import express from "express";
import cors from "cors";
import { mockContacts, mockCountries } from "./data";

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "OK", timestamp: new Date().toISOString() });
});

// Contacts endpoint
app.get("/contacts", (req, res) => {
  try {
    res.json({
      success: true,
      data: mockContacts,
    });
  } catch (error) {
    console.error("Error fetching contacts:", error);
    res.status(500).json({
      success: false,
      error: "Internal server error",
    });
  }
});

// Countries endpoint
app.get("/countries", (req, res) => {
  try {
    res.json({
      success: true,
      data: mockCountries,
    });
  } catch (error) {
    console.error("Error fetching countries:", error);
    res.status(500).json({
      success: false,
      error: "Internal server error",
    });
  }
});

app.listen(port, () => {
  console.log(`API server running on http://localhost:${port}`);
});
