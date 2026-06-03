import { Request, Response, NextFunction } from 'express';

export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
    console.error(err);
    const status = err.message === 'Invalid credentials' ||
        err.message === 'Email already registered' ||
        err.message === 'Invalid refresh token' ||
        err.message.startsWith('Authentication required')
        ? 401
        : 500;
    res.status(status).json({
        success: false,
        message: status === 500 ? 'Internal Server Error' : err.message,
        error: err.message,
    });
}
