const {test}=require('node:test');
const assert=require('node:assert/strict');
const {fresh,forDay,complete,pickPending}=require('./daily-model.js');
const data=require('./demo-data.json');

test('la palabra de hoy permanece al consultar o recargar el estado',()=>{
  const state=fresh();
  const first=forDay(state,'2026-09-21',[1,2,3]);
  const restored=JSON.parse(JSON.stringify(state));
  assert.deepEqual(forDay(restored,'2026-09-21',[1,2,3]),first);
  assert.equal(restored.queue.length,2);
  assert.equal(restored.history.length,1);
});

test('dos vueltas completas contienen cada palabra exactamente una vez',()=>{
  const ids=data.words.map(w=>w.id),state=fresh(),rounds=[];
  for(let cycle=0;cycle<2;cycle++){
    const round=[];
    for(let day=0;day<ids.length;day++)round.push(forDay(state,`${cycle}-${day}`,ids).wordId);
    assert.equal(new Set(round).size,ids.length);
    assert.deepEqual([...round].sort((a,b)=>a-b),[...ids].sort((a,b)=>a-b));
    rounds.push(round);
  }
  assert.notEqual(rounds[0].at(-1),rounds[1][0]);
  assert.equal(state.cycle,2);
});

test('incluso cuando el azar lo propone, no repite al cruzar una vuelta',()=>{
  const state=fresh();state.lastId=1;
  assert.notEqual(forDay(state,'hoy',[1,2,3],()=>.999).wordId,1);
});

test('concede 100 XP una vez por día y conserva la palabra tras completar',()=>{
  const state=fresh();const daily=forDay(state,'hoy',[1,2]);
  assert.equal(complete(state,'hoy'),100);
  assert.equal(complete(state,'hoy'),0);
  assert.equal(complete(state,'día inexistente'),0);
  assert.equal(state.xp,100);
  assert.equal(forDay(state,'hoy',[1,2]).wordId,daily.wordId);
  forDay(state,'mañana',[1,2]);assert.equal(complete(state,'mañana'),100);
  assert.equal(state.xp,200);
});

test('solo recomienda juegos pendientes y soporta un mapa terminado',()=>{
  const games=[{gameId:1},{gameId:2},{gameId:3}];
  for(let i=0;i<100;i++)assert.equal(pickPending(games,[1,3]).gameId,2);
  assert.equal(pickPending(games,[1,2,3]),null);
  assert.equal(pickPending([],[]),null);
});
