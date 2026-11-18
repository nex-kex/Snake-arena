// Типы сообщений протокола. См. docs/protocol.md

export type Dir = "up" | "down" | "left" | "right";
export type Point = [number, number];

export interface Snake {
  id: string;
  name: string;
  body: Point[]; // голова — первый элемент
  dir: Dir;
  alive: boolean;
}

export interface GameState {
  tick: number;
  snakes: Snake[];
  food: Point[];
  scores: Record<string, number>;
}

// TODO(У2): ServerMessage = Welcome | StateUpdate | Players | Scores | GameEvent | ErrorMsg
// TODO(У2): ClientMessage = Join | Command
