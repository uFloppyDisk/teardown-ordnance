---@alias TVec table<number, number, number> Vector { x, y, z }
---@alias TColour table<number, number, number, number?> Colour table { R0-255, G0-255, B0-255, alpha?0-1 }

---@alias TDebugPosition table<TVec, TColour>
---@alias TDebugLine table<TVec, TVec, TColour>

---@alias TConfigMapping { variable: string, value_type: "boolean" | "int" | "float" | "string", value_default: any  }
---@alias TConfigOption { type: string, mapping: TConfigMapping, name: string, category?: string, variant?: string, value_unit?: string, value_digits?: number, value_min?: number, value_max?: number }
