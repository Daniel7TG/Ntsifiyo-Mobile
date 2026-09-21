/* Rotación local de demostración. La recompensa real debe concederla el backend. */
(function (root) {
  function shuffle(ids, random = Math.random) {
    const result = [...new Set(ids)];
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
  }
  function fresh() { return { queue: [], cycle: 0, lastId: null, days: {}, history: [], xp: 0 }; }
  function forDay(state, day, ids, random = Math.random) {
    if (!ids.length) return null;
    if (state.days[day]) return state.days[day];
    const valid = new Set(ids);
    state.queue = state.queue.filter(id => valid.has(id));
    if (!state.queue.length) {
      state.queue = shuffle(ids, random);
      if (state.queue.length > 1 && state.queue[0] === state.lastId) {
        [state.queue[0], state.queue[1]] = [state.queue[1], state.queue[0]];
      }
      state.cycle++;
    }
    const wordId = state.queue.shift();
    state.lastId = wordId;
    const daily = { wordId, completed: false, cycle: state.cycle };
    state.days[day] = daily;
    state.history.push({ day, wordId, cycle: state.cycle });
    return daily;
  }
  function complete(state, day) {
    const daily = state.days[day];
    if (!daily || daily.completed) return 0;
    daily.completed = true;
    state.xp += 100;
    return 100;
  }
  function pickPending(games, completed, random = Math.random) {
    const done = new Set(completed);
    const pending = games.filter(g => !done.has(g.gameId));
    return pending.length ? pending[Math.floor(random() * pending.length)] : null;
  }
  const api = { shuffle, fresh, forDay, complete, pickPending };
  root.DailyDemo = api;
  if (typeof module !== 'undefined') module.exports = api;
})(typeof window === 'undefined' ? globalThis : window);
