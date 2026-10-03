local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Modux = require(ServerScriptService.server.Modux)

export type Handler = (...any) -> ...any

const ENDPOINT_NAME = "Dev"

const DevService = Modux.Service("DevService", { Priority = 990 })

function DevService:Setup()
	self.Enabled = RunService:IsStudio() :: boolean
	self.Handlers = {} :: { [string]: Handler }
	self.Endpoint = nil :: BindableFunction?
end

function DevService:Register(name: string, handler: Handler)
	if not self.Enabled then
		return
	end
	if self.Handlers[name] ~= nil then
		warn(`[DevService] command "{name}" registered twice; keeping the latest`)
	end
	self.Handlers[name] = handler
end

function DevService:Invoke(name: unknown, arguments: { n: number, [number]: any }): ...any
	if typeof(name) ~= "string" then
		return false, "command name must be a string"
	end

	const handler = self.Handlers[name]
	if handler == nil then
		const available = {}
		for registered in self.Handlers do
			table.insert(available, registered)
		end
		table.sort(available)
		return false, `unknown command "{name}". Available: {table.concat(available, ", ")}`
	end

	const outcome = table.pack(pcall(handler, table.unpack(arguments, 1, arguments.n)))
	if not outcome[1] then
		return false, tostring(outcome[2])
	end
	return table.unpack(outcome, 2, outcome.n)
end

DevService:OnInit(function(self)
	self:Setup()
	if not self.Enabled then
		return
	end

	const existing = ServerStorage:FindFirstChild(ENDPOINT_NAME)
	if existing then
		existing:Destroy()
	end

	const endpoint = Instance.new("BindableFunction")
	endpoint.Name = ENDPOINT_NAME
	endpoint.OnInvoke = function(name: unknown, ...: any): ...any
		return self:Invoke(name, table.pack(...))
	end
	endpoint.Parent = ServerStorage
	self.Endpoint = endpoint
end)

return DevService
