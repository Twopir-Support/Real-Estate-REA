#!/usr/bin/env bash
# Deploys TC Apex (classes + triggers) and runs only the TC test classes with coverage.
# Usage: scripts/run-tc-tests.sh [org-alias]   (default REA-Dev)
set -e
ORG=${1:-REA-Dev}
cd "$(dirname "$0")/.."
TESTS=$(ls force-app/main/default/classes/TC_*Test.cls | xargs -n1 basename | sed 's/\.cls$//')
ARGS=""; for t in $TESTS; do ARGS="$ARGS --tests $t"; done
sf project deploy start -d force-app/main/default/classes -d force-app/main/default/triggers -d force-app/main/default/pages -d force-app/main/default/components -o "$ORG" --test-level RunSpecifiedTests $ARGS --wait 40 --json > .sf-deploy-result.json 2>/dev/null || true
node -e "const r=require('./.sf-deploy-result.json');const s=r.result||{};console.log('deploy:',s.status,'componentErrors',s.numberComponentErrors);[].concat((s.details&&s.details.componentFailures)||[]).forEach(x=>console.log('  C-',x.fullName,'L'+x.lineNumber,x.problem));if(r.message)console.log(r.message)"
CN=""; for t in $TESTS; do CN="$CN --class-names $t"; done
sf apex run test -o "$ORG" $CN --code-coverage --result-format json --wait 30 > .sf-test-result.json 2>/dev/null || true
node -e "
const r=require('./.sf-test-result.json');const res=r.result||{};const s=res.summary||{};
console.log('tests:',s.outcome,'ran',s.testsRan,'pass',s.passing,'fail',s.failing,'testRunCoverage',s.testRunCoverage);
(res.tests||[]).filter(t=>t.Outcome!=='Pass').forEach(t=>console.log('  FAIL',t.FullName,':',(t.Message||'').replace(/\s+/g,' ').slice(0,400),'|',(t.StackTrace||'').split('\n').slice(0,2).join(' / ')));
(res.coverage&&res.coverage.coverage||[]).filter(c=>c.name.startsWith('TC_')&&c.coveredPercent<100).sort((a,b)=>a.coveredPercent-b.coveredPercent).forEach(c=>console.log('  COV',c.name,c.coveredPercent+'%',c.totalCovered+'/'+c.totalLines));
if(r.message)console.log(r.message);"
