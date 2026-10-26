import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppShell } from './AppShell';

export const router = createBrowserRouter([
  {
    element: <AppShell />,
    children: [
      { path: '/', element: <Navigate to="/ask" replace /> },
      { path: '/ask', element: <div /> },
      { path: '/documents', element: <div /> },
      { path: '*', element: <Navigate to="/ask" replace /> },
    ],
  },
]);
