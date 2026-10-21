--!strict

export type ShiftPhase = "Lobby" | "Day" | "Night" | "Results"

export type ShiftConfig = {
	LOBBY_DURATION_SECONDS: number,
	DAY_DURATION_SECONDS: number,
	NIGHT_DURATION_SECONDS: number,
	RESULTS_DURATION_SECONDS: number,
	MAX_PARTY_SIZE: number,
	DAY_TASK_COUNT: number,
	ANOMALIES_PER_NIGHT: number,
	INTERACTION_MAX_DISTANCE: number,
	INTERACTION_COOLDOWN_SECONDS: number,
}

export type ShiftState = {
	phase: ShiftPhase,
	timeRemaining: number,
	shiftNumber: number,
	lastSuccess: boolean,
}

export type ShiftTransition = {
	changed: boolean,
	previous: ShiftPhase,
	current: ShiftPhase,
}

export type AnomalyDefinition = {
	id: string,
	displayName: string,
	weight: number,
	maxDistance: number,
	promptText: string,
	anchorTag: string,
}

export type AnomalyContext = {
	definition: AnomalyDefinition,
	model: Model,
	anchor: BasePart,
	prompt: ProximityPrompt,
	state: { [string]: any },
	resolve: () -> (),
	log: (message: string) -> (),
}

export type AnomalyBehavior = {
	start: (ctx: AnomalyContext) -> (),
	onInteract: (ctx: AnomalyContext, player: Player) -> (),
	resolve: (ctx: AnomalyContext) -> (),
	cleanup: (ctx: AnomalyContext) -> (),
}

return {}
