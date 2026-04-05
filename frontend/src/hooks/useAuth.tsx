import type { ReactNode } from "react";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import type { User } from "../types";

type AuthContextType = {
  token: string | null;
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (fullName: string, email: string, password: string) => Promise<void>;
  requestRegistrationOtp: (fullName: string, email: string, password: string) => Promise<{ message: string; delivery_method: string }>;
  verifyRegistrationOtp: (email: string, otp: string) => Promise<void>;
  setCurrentUser: (user: User | null) => void;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const TOKEN_STORAGE_KEY = "task-platform-token";
const USER_STORAGE_KEY = "task-platform-user";

function readStoredUser(): User | null {
  const rawUser = localStorage.getItem(USER_STORAGE_KEY);
  if (!rawUser) {
    return null;
  }

  try {
    return JSON.parse(rawUser) as User;
  } catch {
    localStorage.removeItem(USER_STORAGE_KEY);
    return null;
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string | null>(localStorage.getItem(TOKEN_STORAGE_KEY));
  const [user, setUser] = useState<User | null>(() => readStoredUser());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function bootstrap() {
      if (!token) {
        localStorage.removeItem(USER_STORAGE_KEY);
        setLoading(false);
        return;
      }

      if (user) {
        setLoading(false);
        return;
      }

      try {
        const profile = await api.me(token);
        setUser(profile);
        localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(profile));
      } catch {
        localStorage.removeItem(TOKEN_STORAGE_KEY);
        localStorage.removeItem(USER_STORAGE_KEY);
        setToken(null);
        setUser(null);
      } finally {
        setLoading(false);
      }
    }
    void bootstrap();
  }, [token, user]);

  const value = useMemo(
    () => ({
      token,
      user,
      loading,
      login: async (email: string, password: string) => {
        const result = await api.login({ email, password });
        localStorage.setItem(TOKEN_STORAGE_KEY, result.access_token);
        localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(result.user));
        setToken(result.access_token);
        setUser(result.user);
      },
      register: async (fullName: string, email: string, password: string) => {
        const result = await api.register({ full_name: fullName, email, password });
        localStorage.setItem(TOKEN_STORAGE_KEY, result.access_token);
        localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(result.user));
        setToken(result.access_token);
        setUser(result.user);
      },
      requestRegistrationOtp: (fullName: string, email: string, password: string) =>
        api.requestRegistrationOtp({ full_name: fullName, email, password }),
      verifyRegistrationOtp: async (email: string, otp: string) => {
        const result = await api.verifyRegistrationOtp({ email, otp });
        localStorage.setItem(TOKEN_STORAGE_KEY, result.access_token);
        localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(result.user));
        setToken(result.access_token);
        setUser(result.user);
      },
      setCurrentUser: (nextUser: User | null) => {
        if (nextUser) {
          localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(nextUser));
        } else {
          localStorage.removeItem(USER_STORAGE_KEY);
        }
        setUser(nextUser);
      },
      logout: async () => {
        if (token) {
          try {
            await api.logout(token);
          } catch {
            // Best-effort sign-out. We still clear local auth state below.
          }
        }
        localStorage.removeItem(TOKEN_STORAGE_KEY);
        localStorage.removeItem(USER_STORAGE_KEY);
        setToken(null);
        setUser(null);
      }
    }),
    [loading, token, user]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}
