import { promises as fs } from "fs";
import path from "path";

export interface AuditDocumentPayload {
  section: string;
  checklistItem: string;
  fileName: string;
  contentType: string;
  base64Data: string;
}

export interface AuditDocumentRecord {
  id: string;
  section: string;
  checklistItem: string;
  fileName: string;
  contentType: string;
  size: number;
  uploadedBy: string;
  uploadedAt: string;
  path: string;
}

const uploadRoot = path.resolve(process.cwd(), "uploads", "audit-documents");
const indexPath = path.join(uploadRoot, "index.json");

export class AuditDocumentsService {
  async listDocuments(uploadedBy: string) {
    const documents = await this.readIndex();
    return documents
      .filter((document) => document.uploadedBy === uploadedBy)
      .sort((a, b) => b.uploadedAt.localeCompare(a.uploadedAt));
  }

  async uploadDocument(payload: AuditDocumentPayload, uploadedBy: string) {
    const section = payload.section?.trim();
    const checklistItem = payload.checklistItem?.trim();
    const fileName = payload.fileName?.trim();

    if (!section || !checklistItem || !fileName || !payload.base64Data) {
      throw new Error("section, checklistItem, fileName, and base64Data are required");
    }

    await fs.mkdir(uploadRoot, { recursive: true });

    const bytes = Buffer.from(payload.base64Data, "base64");
    const id = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
    const safeFileName = fileName.replace(/[^a-zA-Z0-9._-]+/g, "-");
    const storedFileName = `${id}-${safeFileName}`;
    const storedPath = path.join(uploadRoot, storedFileName);
    await fs.writeFile(storedPath, bytes);

    const record: AuditDocumentRecord = {
      id,
      section,
      checklistItem,
      fileName,
      contentType: payload.contentType || "application/octet-stream",
      size: bytes.length,
      uploadedBy,
      uploadedAt: new Date().toISOString(),
      path: storedPath,
    };

    const documents = await this.readIndex();
    documents.push(record);
    await fs.writeFile(indexPath, JSON.stringify(documents, null, 2));

    return record;
  }

  private async readIndex(): Promise<AuditDocumentRecord[]> {
    try {
      const raw = await fs.readFile(indexPath, "utf8");
      return JSON.parse(raw) as AuditDocumentRecord[];
    } catch {
      return [];
    }
  }
}
