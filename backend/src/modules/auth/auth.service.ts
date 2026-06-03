import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { config } from "../../config";
import { prisma } from "../../prisma";

interface RegisterPayload {
  name: string;
  firstName?: string;
  lastName?: string;
  photoUrl?: string;
  email: string;
  password: string;
  role: string;
}

interface LoginPayload {
  email: string;
  password: string;
}

export class AuthService {
  async register(payload: RegisterPayload) {
    const existing = await prisma.user.findUnique({
      where: { email: payload.email },
    });
    if (existing) {
      throw new Error("Email already registered");
    }
    const passwordHash = await bcrypt.hash(payload.password, 12);
    const user = await prisma.user.create({
      data: {
        name: payload.name,
        firstName: payload.firstName || firstNameFromName(payload.name),
        lastName: payload.lastName || lastNameFromName(payload.name),
        photoUrl: payload.photoUrl || null,
        email: payload.email,
        passwordHash,
        role: payload.role || "user",
        refreshTokens: [],
      },
    });
    const token = this.createToken(user.id, user.role);
    const refreshToken = this.createRefreshToken(user.id, user.role);
    await prisma.user.update({
      where: { id: user.id },
      data: { refreshTokens: { push: refreshToken } },
    });
    return { token, refreshToken, user: this.publicUser(user) };
  }

  async updateProfile(
    userId: string,
    payload: {
      firstName?: string;
      lastName?: string;
      name?: string;
      photoUrl?: string | null;
    },
  ) {
    const existing = await prisma.user.findUnique({ where: { id: userId } });
    if (!existing) {
      throw new Error("User not found");
    }

    const firstName =
      payload.firstName?.trim() ??
      existing.firstName ??
      firstNameFromName(existing.name);
    const lastName =
      payload.lastName?.trim() ??
      existing.lastName ??
      lastNameFromName(existing.name);
    const name =
      payload.name?.trim() ||
      [firstName, lastName].filter(Boolean).join(" ").trim() ||
      existing.name;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        name,
        firstName,
        lastName,
        ...(payload.photoUrl !== undefined
          ? { photoUrl: payload.photoUrl?.trim() || null }
          : {}),
      },
    });

    return this.publicUser(user);
  }

  async login(payload: LoginPayload) {
    const user = await prisma.user.findUnique({
      where: { email: payload.email },
    });
    if (!user) {
      throw new Error("Invalid credentials");
    }
    const valid = await bcrypt.compare(payload.password, user.passwordHash);
    if (!valid) {
      throw new Error("Invalid credentials");
    }
    const token = this.createToken(user.id, user.role);
    const refreshToken = this.createRefreshToken(user.id, user.role);
    // Note: Refresh token tracking requires MongoDB replica set, skipping for now
    // await prisma.user.update({
    //     where: { id: user.id },
    //     data: { refreshTokens: { push: refreshToken } },
    // });
    return { token, refreshToken, user: this.publicUser(user) };
  }

  async refreshToken(payload: { refreshToken: string }) {
    const decoded = jwt.verify(
      payload.refreshToken,
      config.jwtRefreshSecret,
    ) as { userId: string; role: string };
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });
    if (!user) {
      throw new Error("Invalid refresh token");
    }
    const token = this.createToken(user.id, user.role);
    return {
      token,
      refreshToken: payload.refreshToken,
      user: this.publicUser(user),
    };
  }

  async getUserById(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new Error("User not found");
    }
    return this.publicUser(user);
  }

  async logout(userId: string) {
    await prisma.user.update({
      where: { id: userId },
      data: { refreshTokens: [] },
    });
  }

  async forgotPassword(_email: string) {
    return;
  }

  async resetPassword(_token: string, _newPassword: string) {
    throw new Error("Password reset is not configured");
  }

  async verifyEmail(_token: string) {
    return;
  }

  private createToken(userId: string, role: string) {
    return jwt.sign({ userId, role }, config.jwtSecret, { expiresIn: "30d" });
  }

  private createRefreshToken(userId: string, role: string) {
    return jwt.sign({ userId, role }, config.jwtRefreshSecret, {
      expiresIn: "30d",
    });
  }

  private publicUser(user: {
    id: string;
    name: string;
    firstName?: string | null;
    lastName?: string | null;
    photoUrl?: string | null;
    email: string;
    role: string;
    createdAt: Date;
    updatedAt: Date;
  }) {
    return {
      id: user.id,
      name: user.name,
      firstName: user.firstName,
      lastName: user.lastName,
      photoUrl: user.photoUrl,
      email: user.email,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}

function firstNameFromName(name: string) {
  return name.trim().split(/\s+/)[0] || "";
}

function lastNameFromName(name: string) {
  const parts = name.trim().split(/\s+/);
  return parts.length > 1 ? parts.slice(1).join(" ") : "";
}
