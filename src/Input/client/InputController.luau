local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Modux = require(StarterPlayer.StarterPlayerScripts.client.Modux)

export type Context = "Gameplay" | "Menu"

export type InputKey = Enum.KeyCode | Enum.UserInputType

export type Binding = {
	Name: string,
	Key: InputKey,
	Keys: { InputKey }?,
	TouchButton: boolean?,
	Priority: number?,
	Position: UDim2?,
}

export type Handle = {
	OnPress: (callback: () -> ()) -> Handle,
	OnRelease: (callback: () -> ()) -> Handle,
	Unbind: () -> (),
	_press: { () -> () },
	_release: { () -> () },
}

export type WorldTapCallback = (screenPosition: Vector2) -> ()

const InputController = Modux.Controller("InputController", { Priority = 900 })

const CLICK_MAX_TRAVEL = 6
const GAMEPAD_WORLD_TAP_ACTION = "WorldTapGamepad"
const GAMEPAD_WORLD_TAP_KEY = Enum.KeyCode.ButtonR2

local function flatPosition(input: InputObject): Vector2
	return Vector2.new(input.Position.X, input.Position.Y)
end

function InputController:Setup()
	self.Context = "Gameplay" :: Context
	self.Handles = {} :: { [string]: Handle }
	self.Listeners = {} :: { (Context) -> () }
	self.WorldTapListeners = {} :: { WorldTapCallback }
	self.ClickOrigin = nil :: Vector2?
end

function InputController:Dispatch(name: string, state: Enum.UserInputState): Enum.ContextActionResult
	const handle = self.Handles[name]
	if not handle then
		return Enum.ContextActionResult.Pass
	end

	const callbacks = if state == Enum.UserInputState.Begin
		then handle._press
		elseif state == Enum.UserInputState.End then handle._release
		else nil

	if callbacks then
		for _, callback in callbacks do
			task.spawn(callback)
		end
	end

	return Enum.ContextActionResult.Sink
end

function InputController:Bind(binding: Binding): Handle
	const handle = {
		_press = {},
		_release = {},
	} :: Handle

	handle.OnPress = function(callback: () -> ()): Handle
		table.insert(handle._press, callback)
		return handle
	end

	handle.OnRelease = function(callback: () -> ()): Handle
		table.insert(handle._release, callback)
		return handle
	end

	handle.Unbind = function()
		self:Unbind(binding.Name)
	end

	self.Handles[binding.Name] = handle

	const keys: { InputKey } = { binding.Key }
	if binding.Keys then
		for _, key in binding.Keys do
			table.insert(keys, key)
		end
	end

	ContextActionService:BindActionAtPriority(
		binding.Name,
		function(name: string, state: Enum.UserInputState): Enum.ContextActionResult
			return self:Dispatch(name, state)
		end,
		binding.TouchButton or false,
		binding.Priority or 0,
		table.unpack(keys)
	)

	if binding.Position then
		ContextActionService:SetPosition(binding.Name, binding.Position)
	end

	return handle
end

function InputController:Unbind(name: string)
	if self.Handles[name] == nil then
		return
	end
	self.Handles[name] = nil
	ContextActionService:UnbindAction(name)
end

function InputController:OnContextChange(callback: (Context) -> ())
	table.insert(self.Listeners, callback)
end

function InputController:SetContext(context: Context)
	if self.Context == context then
		return
	end
	self.Context = context
	self.ClickOrigin = nil
	for _, listener in self.Listeners do
		task.spawn(listener, context)
	end
end

function InputController:OnWorldTap(callback: WorldTapCallback): () -> ()
	table.insert(self.WorldTapListeners, callback)
	return function()
		const index = table.find(self.WorldTapListeners, callback)
		if index then
			table.remove(self.WorldTapListeners, index)
		end
	end
end

function InputController:FireWorldTap(screenPosition: Vector2)
	if self.Context ~= "Gameplay" then
		return
	end
	for _, listener in self.WorldTapListeners do
		task.spawn(listener, screenPosition)
	end
end

function InputController:ScreenCenter(): Vector2
	const camera = Workspace.CurrentCamera
	if camera == nil then
		return Vector2.zero
	end
	const inset = GuiService:GetGuiInset()
	return camera.ViewportSize / 2 - inset
end

function InputController:OnClickBegan(input: InputObject, gameProcessed: boolean)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	self.ClickOrigin = if gameProcessed then nil else flatPosition(input)
end

function InputController:OnClickMoved(input: InputObject)
	const origin = self.ClickOrigin
	if origin == nil or input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	if (flatPosition(input) - origin).Magnitude >= CLICK_MAX_TRAVEL then
		self.ClickOrigin = nil
	end
end

function InputController:OnClickEnded(input: InputObject)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	const origin = self.ClickOrigin
	self.ClickOrigin = nil
	if origin == nil then
		return
	end
	const position = flatPosition(input)
	if (position - origin).Magnitude < CLICK_MAX_TRAVEL then
		self:FireWorldTap(position)
	end
end

function InputController:ListenWorldTap()
	UserInputService.TouchTapInWorld:Connect(function(position: Vector2, processedByUI: boolean)
		if processedByUI then
			return
		end
		self:FireWorldTap(position)
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		self:OnClickBegan(input, gameProcessed)
	end)

	UserInputService.InputChanged:Connect(function(input: InputObject)
		self:OnClickMoved(input)
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		self:OnClickEnded(input)
	end)

	self:Bind({
		Name = GAMEPAD_WORLD_TAP_ACTION,
		Key = GAMEPAD_WORLD_TAP_KEY,
	}).OnPress(function()
		self:FireWorldTap(self:ScreenCenter())
	end)
end

InputController:OnInit(function(self)
	self:Setup()
end)

InputController:OnStart(function(self)
	self:ListenWorldTap()
end)

return InputController
