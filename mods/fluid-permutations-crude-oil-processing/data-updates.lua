-- this is a hack, there's no other way to say it.

-- "somewhere" in the prototype stage only "oil-processing-heavy" (crude oil processing from aai-industry) makes it into productivity modules,
-- i have not been able to pinpoint yet why that's the case, so i'm writing this dirty mod just to force it to function, too much work otherwise.

-- fluid permutations checks if a module has the base recipe before giving productivity to its variations, but at that time in data-final-fixes
-- the crude oil processing recipe itself didn't even make it into the limitations table yet, so we're gonna add it premtively just in case.

-- in data-final-fixes of space exploration there's a bit that clones the limitations from module 3 onto 4 through 9.

-- shoutout to codegreen and jansharp for trying to help on the factorio discord, but its just too deep for now.

table.insert(data.raw.module['productivity-module'  ].limitation, 'oil-processing-heavy')
table.insert(data.raw.module['productivity-module-2'].limitation, 'oil-processing-heavy')
table.insert(data.raw.module['productivity-module-3'].limitation, 'oil-processing-heavy')
