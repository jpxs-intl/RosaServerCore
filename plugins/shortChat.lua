---@type Plugin
local plugin = ...
plugin.name = "Short Chat"
plugin.author = "jdb"
plugin.description = "Rejects very wide chat messages."

plugin.defaultConfig = {
	maxPixelWidth = 2060,
}

local defaultCharacterWidth = 27
local characterWidths = {
	[32] = 14,
	[33] = 16,
	[34] = 22,
	[35] = 36,
	[36] = 29,
	[37] = 52,
	[38] = 37,
	[39] = 10,
	[40] = 20,
	[41] = 20,
	[42] = 28,
	[43] = 36,
	[44] = 16,
	[45] = 19,
	[46] = 16,
	[47] = 24,
	[48] = 29,
	[49] = 29,
	[50] = 29,
	[51] = 29,
	[52] = 29,
	[53] = 29,
	[54] = 29,
	[55] = 29,
	[56] = 29,
	[57] = 29,
	[58] = 16,
	[59] = 16,
	[60] = 36,
	[61] = 36,
	[62] = 36,
	[63] = 25,
	[64] = 55,
	[65] = 38,
	[66] = 31,
	[67] = 41,
	[68] = 39,
	[69] = 34,
	[70] = 30,
	[71] = 43,
	[72] = 38,
	[73] = 17,
	[74] = 17,
	[75] = 34,
	[76] = 28,
	[77] = 47,
	[78] = 39,
	[79] = 43,
	[80] = 31,
	[81] = 43,
	[82] = 33,
	[83] = 29,
	[84] = 31,
	[85] = 37,
	[86] = 38,
	[87] = 54,
	[88] = 35,
	[89] = 35,
	[90] = 30,
	[91] = 20,
	[92] = 24,
	[93] = 20,
	[94] = 25,
	[95] = 27,
	[96] = 18,
	[97] = 29,
	[98] = 35,
	[99] = 28,
	[100] = 34,
	[101] = 31,
	[102] = 16,
	[103] = 34,
	[104] = 31,
	[105] = 16,
	[106] = 16,
	[107] = 31,
	[108] = 16,
	[109] = 47,
	[110] = 31,
	[111] = 31,
	[112] = 34,
	[113] = 33,
	[114] = 23,
	[115] = 25,
	[116] = 16,
	[117] = 30,
	[118] = 29,
	[119] = 42,
	[120] = 30,
	[121] = 30,
	[122] = 24,
	[123] = 18,
	[124] = 28,
	[125] = 18,
	[126] = 31,
	[127] = 27,
	[128] = 29,
	[129] = 27,
	[130] = 16,
	[131] = 30,
	[132] = 28,
	[133] = 54,
	[134] = 28,
	[135] = 28,
	[136] = 18,
	[137] = 58,
	[138] = 29,
	[139] = 16,
	[140] = 55,
	[141] = 27,
	[142] = 30,
	[143] = 27,
	[144] = 27,
	[145] = 16,
	[146] = 16,
	[147] = 28,
	[148] = 28,
	[149] = 19,
	[150] = 27,
	[151] = 54,
	[152] = 18,
	[153] = 54,
	[154] = 25,
	[155] = 16,
	[156] = 51,
	[157] = 27,
	[158] = 24,
	[159] = 35,
	[160] = 14,
	[161] = 16,
	[162] = 28,
	[163] = 29,
	[164] = 36,
	[165] = 35,
	[166] = 28,
	[167] = 26,
	[168] = 18,
	[169] = 40,
	[170] = 19,
	[171] = 26,
	[172] = 36,
	[173] = 19,
	[174] = 40,
	[175] = 18,
	[176] = 21,
	[177] = 36,
	[178] = 18,
	[179] = 18,
	[180] = 18,
	[181] = 30,
	[182] = 29,
	[183] = 16,
	[184] = 18,
	[185] = 18,
	[186] = 20,
	[187] = 26,
	[188] = 52,
	[189] = 52,
	[190] = 52,
	[191] = 25,
	[192] = 38,
	[193] = 38,
	[194] = 38,
	[195] = 38,
	[196] = 38,
	[197] = 38,
	[198] = 51,
	[199] = 41,
	[200] = 34,
	[201] = 34,
	[202] = 34,
	[203] = 34,
	[204] = 17,
	[205] = 17,
	[206] = 17,
	[207] = 17,
	[208] = 39,
	[209] = 39,
	[210] = 43,
	[211] = 43,
	[212] = 43,
	[213] = 43,
	[214] = 43,
	[215] = 36,
	[216] = 43,
	[217] = 37,
	[218] = 37,
	[219] = 37,
	[220] = 37,
	[221] = 35,
	[222] = 31,
	[223] = 35,
	[224] = 29,
	[225] = 29,
	[226] = 29,
	[227] = 29,
	[228] = 29,
	[229] = 29,
	[230] = 48,
	[231] = 28,
	[232] = 31,
	[233] = 31,
	[234] = 31,
	[235] = 31,
	[236] = 16,
	[237] = 16,
	[238] = 16,
	[239] = 16,
	[240] = 31,
	[241] = 31,
	[242] = 31,
	[243] = 31,
	[244] = 31,
	[245] = 31,
	[246] = 31,
	[247] = 36,
	[248] = 31,
	[249] = 30,
	[250] = 30,
	[251] = 30,
	[252] = 30,
	[253] = 30,
	[254] = 34,
	[255] = 30,
}

---@param str string
---@return integer
local function getRockwellWidth(str)
	local width = 0

	for i = 1, #str do
		local code = str:byte(i)
		width = width + (characterWidths[code] or defaultCharacterWidth)
	end

	return width
end

plugin:addHook(
	"PlayerChat",
	function(ply, message)
		local width = getRockwellWidth(message)
		if width > plugin.config.maxPixelWidth then
			ply:sendMessage("Message too long")
			return hook.override
		end
	end
)
