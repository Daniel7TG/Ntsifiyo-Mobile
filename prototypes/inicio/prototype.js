const assets = '../../assets/';
const icon = (name) => `${assets}svgs/juegos/${name}_premium.svg`;
const gameData = [
  ['Memorama', 'memorama', 'memory', 'Encuentra las parejas'],
  ['Quiz', 'quiz', 'words', 'Pon a prueba lo que sabes'],
  ['El Intruso', 'intruso', 'words', 'Descubre cuál es diferente'],
  ['Lotería', 'loteria', 'memory', 'Escucha y encuentra la carta'],
  ['Pares', 'pares', 'memory', 'Une palabras e imágenes'],
  ['Sopa de Letras', 'sopa_letras', 'words', 'Busca palabras escondidas'],
  ['Memoria Rápida', 'memoria_rapida', 'memory', 'Recuerda cada tarjeta'],
  ['Tripas del Gato', 'tripas', 'memory', 'Conecta sin cruzar líneas'],
  ['Completar Oración', 'completar_oracion', 'words', 'Encuentra la palabra que falta'],
];
const mapSummary = () => `<button class="map-summary" data-open="mapa" aria-label="Tu aventura en el mapa: 30% completado"><span class="progress-ring"><span>30%</span></span><span class="map-copy"><small>TU AVENTURA</small><strong>24 de 80 estrellas</strong><span>Sigue en el mapa</span></span><span class="chevron">›</span></button>`;
const nav = () => `<nav class="bottom-nav" aria-label="Navegación de ejemplo">${[['inicio','Inicio'],['explorar','Explorar'],['palabras','Palabras'],['perfil','Perfil']].map(([id,label])=>`<button class="${id==='inicio'?'current':''}" data-nav="${id}"><img src="${assets}svgs/nav/nav_${id}${id==='inicio'?'_fill':''}.svg" alt="">${label}</button>`).join('')}</nav>`;
const tile = ([title, image, category, subtitle]) => `<button class="card game-tile" data-open="${title}" data-category="${category}" data-description="${subtitle}"><img src="${icon(image)}" alt=""><strong>${title}</strong><small>${subtitle}</small></button>`;
const title = (text, action='') => `<div class="section-title"><h4>${text}</h4>${action?`<button class="text-button" data-open="Juegos">${action} ↗</button>`:''}</div>`;
const a = `<div class="welcome"><p class="kicker">QUÉ BUENO VERTE POR AQUÍ</p><h3>¿Qué descubrimos<br>hoy?</h3><p>Un poquito de mazahua, a tu manera.</p></div>
  <button class="card feature" data-open="pronunciacion"><div class="feature-copy"><span class="kicker">DALE VOZ AL MAZAHUA</span><h4>Escucha, repite<br>y sorpréndete.</h4><p>Descubre palabras con tu propia voz.</p><span class="cta">Vamos a practicar <span>↗</span></span></div><img src="${assets}explore/pronunciacion.png" alt=""></button>
  ${title('Abre una nueva puerta')}
  <div class="duo"><button class="card mini-card" data-open="palabras"><span class="glyph">▤</span><strong>Palabras <span class="arrow">↗</span></strong><p>Escucha y descubre<br>su significado.</p></button><button class="card mini-card pink" data-open="historias"><span class="glyph">♫</span><strong>Historias <span class="arrow">↗</span></strong><p>Canciones y leyendas<br>para imaginar.</p></button></div>
  ${title('Un ratito para jugar','Ver todos')}<div class="game-row">${gameData.slice(0,4).map(tile).join('')}</div>`;
const b = `<div class="welcome"><p class="kicker">APRENDE JUGANDO</p><h3>¿A qué jugamos?</h3><p>Elige tu favorito. Tú pones el ritmo.</p></div>
  <div class="filters" role="group" aria-label="Filtrar juegos"><button class="active" data-filter="all" aria-pressed="true">Todos</button><button data-filter="memory" aria-pressed="false">Memoria y parejas</button><button data-filter="words" aria-pressed="false">Palabras</button></div><div class="catalog">${gameData.map(tile).join('')}</div>
  <button class="card small-banner" data-open="pronunciacion"><span class="glyph">◉</span><span><strong>¿Y si pruebas con tu voz?</strong><p>Descubre la práctica de pronunciación.</p></span><span class="chevron">›</span></button>`;
const c = `<div class="welcome guided-welcome"><div><p class="kicker">UN PEQUEÑO DESCUBRIMIENTO</p><h3>Empecemos con<br>una palabra.</h3><p>Yo te acompaño. ¡Vamos!</p></div><img src="${assets}coyote/saludo.webp" alt="Coyote saludando"></div>
  <div class="card word-card"><div class="word-top"><p class="kicker">PARA DESCUBRIR HOY</p><span>Animales</span></div><div class="word-content"><img src="${assets}dictionary/img/16.webp" alt="Conejo"><div><h4>kjuaa</h4><p>conejo</p></div></div><button class="audio-button" id="listen-word">▷ &nbsp; Escuchar la palabra</button><audio id="word-audio" src="${assets}dictionary/audio/16.mp3" preload="none"></audio></div>
  ${title('Ahora, dale vida a lo que aprendes')}
  <div class="steps"><button class="card step step-primary" data-open="pronunciacion"><span class="step-number">1</span><span><strong>Prueba con tu voz</strong><p>Escucha una palabra e intenta decirla.</p></span><span class="chevron">›</span></button><button class="card step" data-open="Memorama"><span class="step-number">2</span><span><strong>Aprende jugando</strong><p>Encuentra las parejas en Memorama.</p></span><span class="chevron">›</span></button></div>
  <p class="quiet-note">Sin prisa. Cada palabra es un paso.</p>
  ${title('¿Prefieres explorar?')}<div class="duo"><button class="card mini-card" data-open="Juegos"><span class="glyph">◇</span><strong>Todos los juegos ↗</strong><p>Encuentra tu favorito.</p></button><button class="card mini-card pink" data-open="historias"><span class="glyph">♫</span><strong>Una historia ↗</strong><p>Escucha e imagina.</p></button></div>`;
const proposals = [
  {id:'a',name:'Descubrir a tu manera',tag:'VARIEDAD CON UNA INVITACIÓN CLARA',body:a,description:'Pronunciación como protagonista, palabras e historias a un toque y juegos para seguir explorando. Un inicio que muestra todo lo que puedes hacer.'},
  {id:'b',name:'Vamos a jugar',tag:'DIRECTO A LO QUE MÁS TE GUSTA',body:b,description:'Un catálogo visual de juegos con filtros sencillos. Ideal si queremos que entrar a la app signifique encontrar rápido algo para jugar.'},
  {id:'c',name:'Un paso a la vez',tag:'MENOS OPCIONES, MÁS ACOMPAÑAMIENTO',body:c,description:'Una palabra con audio real, el coyote y dos siguientes pasos. Una bienvenida tranquila para quienes todavía no saben por dónde empezar.'},
];
document.querySelector('.proposals').innerHTML = proposals.map(p => `<article class="proposal" data-proposal="${p.id}"><div class="proposal-label"><span class="letter">${p.id.toUpperCase()}</span><div><h2>${p.name}</h2><p>${p.tag}</p></div></div><div class="phone"><div class="status-bar"><span>9:41</span><span class="status-icons" aria-hidden="true">▂▅▇ ▰</span></div><div class="app-bar"><strong>Inicio</strong><img class="avatar" src="${assets}coyote/saludo.webp" alt=""></div><div class="screen" tabindex="0" aria-label="Contenido de propuesta ${p.id.toUpperCase()}">${mapSummary()}${p.body}</div>${nav()}</div><p class="proposal-description">${p.description}</p><button class="choose" data-choose="${p.id}" aria-pressed="false"><span>Me gusta esta dirección</span><span>↗</span></button></article>`).join('');
const announce = text => document.getElementById('announcement').textContent = text;
function setView(view) {
  document.querySelectorAll('[data-view]').forEach(b => {b.classList.toggle('active',b.dataset.view===view); b.setAttribute('aria-pressed',String(b.dataset.view===view));});
  document.querySelector('.proposals').classList.toggle('solo',view!=='all');
  document.querySelectorAll('.proposal').forEach(p=>p.hidden=view!=='all'&&p.dataset.proposal!==view);
  if(view!=='c' && view!=='all') document.getElementById('word-audio').pause();
  history.replaceState(null,'',view==='all'?'#comparar':`#${view}`);
}
document.querySelectorAll('[data-view]').forEach(b=>b.addEventListener('click',()=>setView(b.dataset.view)));
document.getElementById('theme-toggle').addEventListener('click',e=>{const b=e.currentTarget;const dark=b.getAttribute('aria-pressed')!=='true';b.setAttribute('aria-pressed',String(dark));b.querySelector('span').textContent=dark?'Modo claro':'Modo oscuro';document.querySelectorAll('.phone').forEach(p=>p.classList.toggle('dark',dark));});
document.querySelectorAll('[data-filter]').forEach(b=>b.addEventListener('click',()=>{document.querySelectorAll('[data-filter]').forEach(x=>{x.classList.toggle('active',x===b);x.setAttribute('aria-pressed',String(x===b));});document.querySelectorAll('.catalog .game-tile').forEach(t=>t.hidden=b.dataset.filter!=='all'&&t.dataset.category!==b.dataset.filter);announce(`Filtro ${b.textContent} aplicado`);}));
document.querySelectorAll('[data-choose]').forEach(b=>b.addEventListener('click',()=>{document.querySelectorAll('[data-choose]').forEach(x=>{x.classList.toggle('selected',x===b);x.setAttribute('aria-pressed',String(x===b));x.firstElementChild.textContent=x===b?'Mi favorita · propuesta '+x.dataset.choose.toUpperCase():'Me gusta esta dirección';});announce('Propuesta '+b.dataset.choose.toUpperCase()+' marcada como favorita');}));
const audio = document.getElementById('word-audio');const listen = document.getElementById('listen-word');
listen.addEventListener('click',async()=>{if(!audio.paused){audio.pause();return;}try{await audio.play();}catch{announce('No se pudo reproducir el audio. Inténtalo de nuevo.');listen.textContent='Reintentar audio';}});
audio.addEventListener('play',()=>listen.textContent='Ⅱ   Escuchando…');audio.addEventListener('pause',()=>listen.textContent='▷   Escuchar la palabra');audio.addEventListener('ended',()=>listen.textContent='▷   Volver a escuchar');
const dialog = document.getElementById('preview-dialog');
const destinations = {
  mapa:['Tu aventura continúa','Desde aquí se abre el mapa con sus zonas y estrellas. Este acceso y su indicador se conservan en las tres propuestas.','explore/map.png'],
  pronunciacion:['Dale voz al mazahua','Este acceso abre la práctica de pronunciación: escuchar una palabra, grabar tu voz y ver el resultado.','explore/pronunciacion.png'],
  palabras:['Una palabra, un descubrimiento','Este acceso abre el diccionario de la app, con imágenes, significado y audio en mazahua.','dictionary/img/16.webp'],
  historias:['Historias para imaginar','Este acceso abre las canciones, leyendas, anécdotas y poemas de la app.','explore/anecdotas.png'],
  explorar:['Un mundo por explorar','Aquí encontrarás el mapa, la pronunciación y el contenido multimedia.','explore/map.png'],
  perfil:['Tu espacio','Aquí se mantienen tus estadísticas, asignaciones y ajustes.'],
};
function showDestination(key,description) {
  audio.pause();
  const content=document.getElementById('dialog-content');
  content.replaceChildren();
  if(key==='Juegos') {
    content.innerHTML='<p class="eyebrow">VISTA DE EJEMPLO</p><h2 id="dialog-title">Elige tu juego</h2><div class="catalog">'+gameData.map(tile).join('')+'</div>';
  } else {
    const [heading,copy,img]=destinations[key]||[key,description||'Desde aquí eliges una actividad de este juego y empiezas a jugar.'];
    const eyebrow=document.createElement('p');eyebrow.className='eyebrow';eyebrow.textContent='DESTINO DE ESTE ACCESO';content.append(eyebrow);
    if(img){const image=document.createElement('img');image.className='dialog-image';image.src=assets+img;image.alt='';content.append(image);}
    const h=document.createElement('h2');h.id='dialog-title';h.textContent=heading;content.append(h);
    const p=document.createElement('p');p.textContent=copy;content.append(p);
    const b=document.createElement('button');b.className='dialog-action';b.textContent='Volver al prototipo';b.onclick=()=>dialog.close();content.append(b);
  }
  if(!dialog.open)dialog.showModal();
}
document.addEventListener('click',e=>{const button=e.target.closest('[data-open],[data-nav]');if(!button)return;const key=button.dataset.open||button.dataset.nav;if(key==='inicio'){button.closest('.phone').querySelector('.screen').scrollTo({top:0,behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});return;}showDestination(key,button.dataset.description);});
document.querySelector('.close-dialog').addEventListener('click',()=>dialog.close());
dialog.addEventListener('click',e=>{if(e.target===dialog){const r=dialog.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)dialog.close();}});
const initial=location.hash.slice(1);if(['a','b','c'].includes(initial))setView(initial);
