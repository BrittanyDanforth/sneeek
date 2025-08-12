local Transitions = {}

local TweenService = game:GetService("TweenService")

function Transitions.crossfade(oldFrame: Frame?, newFrame: Frame)
	if oldFrame and oldFrame ~= newFrame then
		oldFrame.Visible = true
		newFrame.Visible = true
		oldFrame.BackgroundTransparency = oldFrame.BackgroundTransparency or 1
		newFrame.BackgroundTransparency = 1
		TweenService:Create(oldFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		TweenService:Create(newFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
		task.delay(0.18, function()
			if oldFrame ~= newFrame then oldFrame.Visible = false end
		end)
	else
		newFrame.Visible = true
	end
end

function Transitions.slideSwap(container: Frame, fromFrame: Frame?, toFrame: Frame, direction: number)
	local w = container.AbsoluteSize.X
	toFrame.Visible = true
	toFrame.Position = UDim2.new(direction > 0 and 1 or -1, 0, 0, 0)
	TweenService:Create(toFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
	if fromFrame and fromFrame ~= toFrame then
		TweenService:Create(fromFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(direction > 0 and -0.25 or 0.25,0,0,0), BackgroundTransparency = 1}):Play()
		task.delay(0.22, function() fromFrame.Visible = false fromFrame.Position = UDim2.new(0,0,0,0) end)
	end
end

function Transitions.moveUnderline(underline: Frame, targetBtn: TextButton)
	underline.Visible = true
	local goal = {Position = UDim2.new(0, targetBtn.AbsolutePosition.X - targetBtn.Parent.AbsolutePosition.X, 1, -2), Size = UDim2.new(0, targetBtn.AbsoluteSize.X, 0, 3)}
	TweenService:Create(underline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

return Transitions