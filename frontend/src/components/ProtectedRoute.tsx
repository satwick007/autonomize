import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function ProtectedRoute({ children }: { children: JSX.Element }) {
  const { token, loading } = useAuth();

  if (loading) {
    return <div className="page-shell centered">Loading your workspace...</div>;
  }

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return children;
}
