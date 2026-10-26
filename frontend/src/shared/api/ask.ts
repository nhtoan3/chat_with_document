import { postJson } from './client';

export interface AskResponse {
  answer: string;
  latency_ms: number;
}

export function ask(question: string): Promise<AskResponse> {
  return postJson<AskResponse>('/ask', { question });
}
