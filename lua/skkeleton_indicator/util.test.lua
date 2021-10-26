local snake_case = require'skkeleton_indicator.util'.snake_case
local snake_case_dict = require'skkeleton_indicator.util'.snake_case_dict

describe('snake_case', function()
  for _, c in ipairs{
    {case = 'all lower', str = 'abcdefg', expected = 'abcdefg'},
    {case = '2 parts', str = 'abcdEfg', expected = 'abcd_efg'},
    {case = '3 parts', str = 'aBcdEfg', expected = 'a_bcd_efg'},
  } do
    it(c.case, function()
      assert.equals(c.expected, snake_case(c.str))
    end)
  end
end)

describe('snake_case_dict', function()
  it('makes opts to lower case keys', function()
    assert.same({
      module_name = 'skkeleton_indicator',
      eiji_hl_name = 'SkkeletonIndicatorEiji',
      hira_hl_name = 'SkkeletonIndicatorHira',
      kata_hl_name = 'SkkeletonIndicatorKata',
      hankata_hl_name = 'SkkeletonIndicatorHankata',
      eiji_text = '英字',
      hira_text = 'ひら',
      kata_text = 'カタ',
      hankata_text = '半ｶﾀ',
      fade_out_ms = 3000,
      ignore_ft = {},
      -- same() cannot detect function to be the same.
      --buf_filter = function() return true end,
    }, snake_case_dict{
      moduleName = 'skkeleton_indicator',
      eijiHlName = 'SkkeletonIndicatorEiji',
      hiraHlName = 'SkkeletonIndicatorHira',
      kataHlName = 'SkkeletonIndicatorKata',
      hankataHlName = 'SkkeletonIndicatorHankata',
      eijiText = '英字',
      hiraText = 'ひら',
      kataText = 'カタ',
      hankataText = '半ｶﾀ',
      fadeOutMs = 3000,
      ignoreFt = {},
      --bufFilter = function() return true end,
    })
  end)
end)
