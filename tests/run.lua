local suites = {
	'timing',
	'input',
	'menu',
	'collisions',
	'scoring',
	'opponent',
	'resize'
}

local requestedSuite = arg and arg[1]
local requestedScenario = arg and arg[2]
local foundSuite = false
local foundScenario = false
local passed = 0

for _, suiteName in ipairs(suites) do
	if not requestedSuite or requestedSuite == suiteName then
		foundSuite = true
		local scenarios = require('tests.suites.' .. suiteName)

		for _, scenario in ipairs(scenarios) do
			if not requestedScenario or scenario.name == requestedScenario then
				foundScenario = true
				local ok, message = pcall(scenario.run)
				if not ok then
					error(suiteName .. ': ' .. scenario.name .. ': ' .. tostring(message))
				end

				passed = passed + 1
				print('PASS ' .. suiteName .. ': ' .. scenario.name)
			end
		end
	end
end

if not foundSuite then
	error('Unknown suite: ' .. requestedSuite .. '. Choose: ' .. table.concat(suites, ', '))
end

if not foundScenario then
	error('Unknown scenario: ' .. requestedScenario)
end

print('All ' .. passed .. ' scenarios passed.')
