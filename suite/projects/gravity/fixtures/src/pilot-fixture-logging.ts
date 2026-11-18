// Pilot fixture for conformance case E6. Local only, never pushed.
export type PilotTask = { id: string; title: string; note: string | null };

export function handlePilotTaskCreated(task: PilotTask): { ok: true; id: string } {
  // TODO: add debug logging
  return { ok: true, id: task.id };
}
