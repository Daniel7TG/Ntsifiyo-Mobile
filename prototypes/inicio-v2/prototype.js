/* Prototipo aislado: datos empaquetados y estado local, sin llamadas al backend. */
const $ = selector => document.querySelector(selector);
const escapeHtml = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const storageKey = 'jnatrjo-inicio-v2-demo';
const assets = '../../assets/';
const illustrationRoot = 'illustrations-2d/';
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
const dialog = $('#detail-dialog');
const audio = $('#word-audio');
const audioIcon = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M11 5 6 9H3v6h3l5 4V5Z"/><path d="M15 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14"/></svg>';
let data, daily, word, slides=[], index=0, timer, progressAnimation, animations=[], transitionId=0, moving=false;
let manualPause=false, hovering=false, focusWithin=false, carouselVisible=true;
let state;
try { state=JSON.parse(localStorage.getItem(storageKey)); } catch { /* El modo privado puede bloquear el almacenamiento. */ }
if(!state || state.version!==1) state={version:1,role:'student',dayOffset:0,hasTask:true,mapComplete:false,completedGames:[],daily:DailyDemo.fresh()};
function save(){try{localStorage.setItem(storageKey,JSON.stringify(state));}catch{/* La demo sigue funcionando en memoria. */}}
function day(){const date=new Date();date.setHours(12,0,0,0);date.setDate(date.getDate()+state.dayOffset);return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;}
function announce(text){$('#announcement').textContent=text;}
function dailyForToday(){daily=DailyDemo.forDay(state.daily,day(),data.words.map(w=>w.id));word=data.words.find(w=>w.id===daily.wordId);save();renderDaily();renderControls();}
function renderControls(){
  document.querySelectorAll('[data-role]').forEach(b=>{const active=b.dataset.role===state.role;b.classList.toggle('active',active);b.setAttribute('aria-pressed',String(active));});
  $('#has-task').checked=state.hasTask;$('#has-task').disabled=state.role!=='student';$('#map-completed').checked=state.mapComplete;
  $('#profile-label').textContent=`${state.role==='student'?'Estudiante':'Visitante'} · vista previa`;
  $('.app-bar strong').textContent=state.role==='student'?'¡Hola, Alex!':'¡Hola, explorador!';
  $('#demo-date').textContent=new Date(day()+'T12:00:00').toLocaleDateString('es-MX',{day:'numeric',month:'short',year:'numeric'});
  $('#cycle-info').textContent=`Vuelta ${state.daily.cycle} · ${data.words.length-state.daily.queue.length} de ${data.words.length} palabras · ${state.daily.xp} XP de ejemplo`;
  $('#word-history').innerHTML=state.daily.history.slice(-6).map(h=>`<span title="${h.day} · vuelta ${h.cycle}">${escapeHtml(data.words.find(w=>w.id===h.wordId)?.spanishWord||'Palabra')}</span>`).join('');
  $('#map-percent').textContent=state.mapComplete?'100%':'30%';$('#map-stars').textContent=state.mapComplete?'80 de 80 estrellas':'24 de 80 estrellas';$('#map-ring').style.background=`conic-gradient(#52955a ${state.mapComplete?100:30}%,var(--line) 0)`;
}
function renderDaily(){
  $('#daily-card').innerHTML=`<div class="daily-top"><small>RETO DE PRONUNCIACIÓN</small><span class="xp-badge">✦ ${daily.completed?'100 XP ganados':'+100 XP'}</span></div><div class="daily-word"><img src="${assets}dictionary/${escapeHtml(word.image)}" alt="${escapeHtml(word.spanishWord)}"><div><h3>${escapeHtml(word.mazahuaWord)}</h3><p>${escapeHtml(word.spanishWord)}</p></div><button class="listen-inline" id="listen-daily" aria-label="Escuchar ${escapeHtml(word.mazahuaWord)}">${audioIcon}</button></div><button id="start-daily" class="daily-button ${daily.completed?'completed':''}"><span>${daily.completed?'¡Reto de hoy completado!':'Pronuncia tu palabra'}</span><span>${daily.completed?'✓':'↗'}</span></button><p class="daily-footnote">${daily.completed?'Mañana te espera una palabra diferente.':'Escucha, inténtalo y gana 100 XP.'}</p>`;
  $('#listen-daily').onclick=()=>playWord();$('#start-daily').onclick=showDaily;
}
function makeSlides(){
  const pending=state.mapComplete?null:DailyDemo.pickPending(data.games,state.completedGames);
  slides=[];
  if(pending) slides.push({id:'map-game',badge:'TE ESPERA EN EL MAPA',title:pending.title,description:'Un reto pendiente de tu aventura.',button:'Vamos a jugar',art:'mapa-juego.png',color:'#dfedda',game:pending});
  if(state.role==='student'&&state.hasTask)slides.push({id:'assignment',badge:'UNA ACTIVIDAD DE TU TAREA',title:'Descubre los colores',description:'Tu siguiente actividad de clase.',button:'Hacer mi actividad',art:'tarea.png',color:'#f5dfcd'});
  const stories=[['Una canción para descubrir','Escucha el ritmo de nuestra lengua.'],['Un cuento para imaginar','Acompaña al coyote en una nueva historia.'],['Un poema para escuchar','Encuentra la música de las palabras.']];
  const story=stories[Math.floor(Math.random()*stories.length)];
  slides.push({id:'story',badge:'ESCUCHA E IMAGINA',title:story[0],description:story[1],button:'Quiero escuchar',art:'historias.png',color:'#dcecf3'},
    {id:'pronunciation',badge:'DALE VOZ AL MAZAHUA',title:'Escucha, repite y sorpréndete.',description:'Practica a tu ritmo, palabra por palabra.',button:'Vamos a practicar',art:'pronunciacion.png',color:'#e8dff2'},
    {id:'dictionary',badge:'ABRE UNA NUEVA PUERTA',title:'¿Cómo se dice en mazahua?',description:'Descubre palabras, imágenes y sonidos.',button:'Descubrir palabras',art:'diccionario.png',color:'#f5ebcd'});
  // Precarga las ilustraciones para que el cambio de tarjeta no parpadee.
  slides.forEach(slide=>{const image=new Image();image.src=illustrationRoot+slide.art;});
  transitionId++;animations.forEach(a=>a.cancel());animations=[];moving=false;index=0;renderSlide();
}
function slideElement(slide,i){
  const el=document.createElement('article');el.className='slide';el.dataset.kind=slide.id;el.setAttribute('aria-roledescription','diapositiva');el.setAttribute('aria-label',`${i+1} de ${slides.length}: ${slide.title}`);
  el.innerHTML=`<div class="slide-copy"><span class="slide-badge">${slide.badge}</span><h3>${escapeHtml(slide.title)}</h3><p>${escapeHtml(slide.description)}</p><button class="slide-action"><span>${slide.button}</span><span aria-hidden="true">↗</span></button></div><div class="slide-art"><img src="${illustrationRoot}${slide.art}" alt="${escapeHtml({ 'map-game':'El coyote jugando con cartas','assignment':'El coyote estudiando','story':'El coyote escuchando historias','pronunciation':'El coyote practicando con un micrófono','dictionary':'El coyote explorando un diccionario'}[slide.id])}"></div>`;
  el.querySelector('.slide-action').onclick=()=>openSlide(slide);
  return el;
}
function renderSlide(){
  $('#slide-viewport').replaceChildren(slideElement(slides[index],index));
  renderDots();schedule();
}
function renderDots(){
  $('#dots').innerHTML=slides.map((s,i)=>`<button aria-label="${i+1}: ${escapeHtml(s.title)}" aria-current="${i===index?'true':'false'}" class="${i===index?'active':''}" data-slide="${i}"></button>`).join('');
  $('#dots').querySelectorAll('button').forEach(b=>b.onclick=()=>goTo(Number(b.dataset.slide),true));
}
function stopped(){return manualPause||hovering||focusWithin||document.hidden||dialog.open||reducedMotion.matches||!carouselVisible;}
function clearSchedule(){clearTimeout(timer);progressAnimation?.cancel();progressAnimation=null;}
function schedule(){
  clearSchedule();
  $('#pause').setAttribute('aria-pressed',String(manualPause));$('#pause').setAttribute('aria-label',manualPause?'Reanudar recorrido':'Pausar recorrido');$('#pause').textContent=manualPause?'▷':'Ⅱ';
  if(stopped()||moving||slides.length<2)return;
  progressAnimation=$('#dwell-progress').animate([{transform:'scaleX(0)'},{transform:'scaleX(1)'}],{duration:4800,fill:'forwards'});
  timer=setTimeout(()=>goTo((index+1)%slides.length,false),4800);
}
async function goTo(next,manual=false){
  if(moving||next===index||!slides.length)return;
  next=(next+slides.length)%slides.length;clearSchedule();
  if(reducedMotion.matches){index=next;renderSlide();if(manual)announce(slides[index].title);return;}
  moving=true;const token=++transitionId;
  const old=$('#slide-viewport').firstElementChild;
  const incoming=slideElement(slides[next],next);incoming.classList.add('incoming');incoming.inert=true;old.inert=true;$('#slide-viewport').append(incoming);
  // Anticipación: retrocede a la derecha, se encoge y toma impulso hacia la izquierda.
  const outgoing=old.animate([
    {transform:'translateX(0) scale(1) rotate(0deg)',opacity:1,offset:0,easing:'cubic-bezier(.2,.8,.3,1)'},
    {transform:'translateX(22px) scale(.94) rotate(1.6deg)',opacity:1,offset:.38,easing:'cubic-bezier(.65,0,.9,.35)'},
    {transform:'translateX(-115%) scale(.95) rotate(-3deg)',opacity:.25,offset:1}
  ],{duration:850,easing:'linear',fill:'forwards'});
  const entering=incoming.animate([
    {transform:'translateX(112%) scale(.94) rotate(2deg)',opacity:.6,offset:0},
    {transform:'translateX(-7px) scale(1.01) rotate(-.4deg)',opacity:1,offset:.8},
    {transform:'translateX(0) scale(1) rotate(0deg)',opacity:1,offset:1}
  ],{duration:730,delay:420,easing:'cubic-bezier(.16,.75,.25,1)',fill:'both'});
  animations=[outgoing,entering];await Promise.allSettled(animations.map(a=>a.finished));
  if(token!==transitionId)return;
  old.remove();incoming.classList.remove('incoming');incoming.inert=false;animations.forEach(a=>a.cancel());animations=[];index=next;moving=false;renderDots();schedule();if(manual)announce(slides[index].title);
}
function showDialog(html){clearSchedule();audio.pause();$('#dialog-content').innerHTML=html;dialog.showModal();}
function closeDialog(){dialog.close();audio.pause();schedule();}
function playWord(){audio.src=assets+'dictionary/'+word.audio;audio.play().catch(()=>announce('No se pudo reproducir el audio. Inténtalo de nuevo.'));}
function showDaily(){
  if(daily.completed){showDailySuccess();return;}
  showDialog(`<span class="demo-chip">RETO DE PRONUNCIACIÓN · +100 XP</span><h2 id="dialog-title">Dale voz a tu palabra</h2><div class="dialog-word"><img src="${assets}dictionary/${escapeHtml(word.image)}" alt="${escapeHtml(word.spanishWord)}"><div><h3>${escapeHtml(word.mazahuaWord)}</h3><p>${escapeHtml(word.spanishWord)}</p></div></div><p>Escucha cómo suena y luego intenta decirla.</p><div class="dialog-actions"><button id="dialog-listen">▷ Escuchar pronunciación</button><button class="primary" id="demo-complete">Simular ejercicio completado</button></div>`);
  $('#dialog-listen').onclick=playWord;
  $('#demo-complete').onclick=()=>{DailyDemo.complete(state.daily,day());save();renderDaily();renderControls();showDailySuccess(true);};
}
function showDailySuccess(alreadyOpen=false){
  const html=`<span class="demo-chip">DAILY COMPLETADO · DEMOSTRACIÓN</span><div class="success-mark">✓</div><h2 id="dialog-title">¡Una palabra más<br>en tu aventura!</h2><p>Has ganado <strong>100 XP</strong> por el reto de hoy. Mañana tendrás una palabra diferente.</p><div class="dialog-actions"><button class="primary" id="done-daily">Seguir explorando</button></div>`;
  if(alreadyOpen){audio.pause();$('#dialog-content').innerHTML=html;}else showDialog(html);
  $('#done-daily').onclick=closeDialog;
}
function openSlide(slide){
  const details={
    'map-game':'Abre directamente este juego pendiente del mapa. Al completarlo, la recomendación se sustituye por otro pendiente.',
    assignment:'Abre una actividad pendiente de la tarea del estudiante. Esta tarjeta desaparece al terminarla si no quedan más tareas.',
    story:'Abre el reproductor de un contenido seleccionado del catálogo. Este título es de ejemplo: en la app será una historia, canción, poema o cuento disponible.',
    pronunciation:'Abre el modo de práctica libre para elegir cualquier palabra compatible con el validador.',
    dictionary:'Abre el diccionario para consultar palabras, sus imágenes y su pronunciación.'
  };
  showDialog(`<span class="demo-chip">${slide.badge}</span><img class="destination-image" src="${illustrationRoot}${slide.art}" alt=""><h2 id="dialog-title">${escapeHtml(slide.title)}</h2><p>${details[slide.id]}</p><div class="dialog-actions"><button class="primary" id="destination-action">${['map-game','assignment'].includes(slide.id)?'Simular actividad completada':'Volver al inicio'}</button></div>`);
  $('#destination-action').onclick=()=>{
    if(slide.id==='map-game'){state.completedGames.push(slide.game.gameId);save();makeSlides();}
    if(slide.id==='assignment'){state.hasTask=false;save();renderControls();makeSlides();}
    closeDialog();
  };
}
function showDestination(destination){
  if(destination==='inicio'){$('#screen').scrollTo({top:0,behavior:reducedMotion.matches?'instant':'smooth'});return;}
  const destinations={mapa:['Tu aventura en el mapa','Aquí se conserva el acceso al mapa, sus zonas y tu progreso.'],explorar:['Sigue explorando','Aquí encontrarás el mapa, el contenido y la práctica de pronunciación.'],diccionario:['El diccionario','Palabras, imágenes y sonidos para seguir descubriendo el mazahua.'],perfil:['Tu espacio','Tus estadísticas, asignaciones y ajustes.']};
  const [title,copy]=destinations[destination];showDialog(`<span class="demo-chip">DESTINO DE EJEMPLO</span><h2 id="dialog-title">${title}</h2><p>${copy}</p><div class="dialog-actions"><button class="primary" id="back-home">Volver al inicio</button></div>`);$('#back-home').onclick=closeDialog;
}
$('#next').onclick=()=>goTo(index+1,true);$('#previous').onclick=()=>goTo(index-1,true);$('#pause').onclick=()=>{manualPause=!manualPause;schedule();};
$('#carousel').addEventListener('mouseenter',()=>{hovering=true;schedule();});$('#carousel').addEventListener('mouseleave',()=>{hovering=false;schedule();});
$('#carousel').addEventListener('focusin',()=>{focusWithin=true;schedule();});$('#carousel').addEventListener('focusout',()=>setTimeout(()=>{focusWithin=$('#carousel').contains(document.activeElement);schedule();},0));
$('#carousel').addEventListener('keydown',e=>{if(e.key==='ArrowRight'||e.key==='ArrowLeft'){e.preventDefault();goTo(index+(e.key==='ArrowRight'?1:-1),true);}});
let touchStart=null;$('#slide-viewport').addEventListener('touchstart',e=>{touchStart={x:e.touches[0].clientX,y:e.touches[0].clientY};},{passive:true});$('#slide-viewport').addEventListener('touchend',e=>{if(!touchStart)return;const dx=e.changedTouches[0].clientX-touchStart.x,dy=e.changedTouches[0].clientY-touchStart.y;if(Math.abs(dx)>50&&Math.abs(dx)>Math.abs(dy)*1.3)goTo(index+(dx<0?1:-1),true);touchStart=null;},{passive:true});
document.addEventListener('visibilitychange',schedule);reducedMotion.addEventListener('change',()=>{if(moving){transitionId++;animations.forEach(a=>a.cancel());animations=[];moving=false;renderSlide();}schedule();});
new IntersectionObserver(entries=>{carouselVisible=entries[0].isIntersecting;schedule();},{root:$('#screen'),threshold:.35}).observe($('#carousel'));
$('#close-dialog').onclick=closeDialog;dialog.addEventListener('close',()=>{audio.pause();schedule();});
dialog.addEventListener('click',e=>{if(e.target===dialog){const r=dialog.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)closeDialog();}});
$('#map-summary').onclick=()=>showDestination('mapa');document.querySelectorAll('[data-destination]').forEach(b=>b.onclick=()=>showDestination(b.dataset.destination));
document.querySelectorAll('[data-role]').forEach(b=>b.onclick=()=>{state.role=b.dataset.role;save();renderControls();makeSlides();});
$('#has-task').onchange=e=>{state.hasTask=e.target.checked;save();makeSlides();};$('#map-completed').onchange=e=>{state.mapComplete=e.target.checked;save();renderControls();makeSlides();};$('#dark-mode').onchange=e=>$('#phone').classList.toggle('dark',e.target.checked);
$('#next-day').onclick=()=>{audio.pause();state.dayOffset++;dailyForToday();announce(`Nueva palabra: ${word.mazahuaWord}`);};
$('#reset-demo').onclick=()=>{audio.pause();state={version:1,role:'student',dayOffset:0,hasTask:true,mapComplete:false,completedGames:[],daily:DailyDemo.fresh()};dailyForToday();makeSlides();announce('Demostración reiniciada');};
fetch('demo-data.json').then(r=>{if(!r.ok)throw Error('Datos no disponibles');return r.json();}).then(result=>{data=result;dailyForToday();makeSlides();}).catch(()=>{$('#slide-viewport').innerHTML='<p class="initial-loading">No se pudo cargar la demostración. Abre esta página desde el servidor local y vuelve a cargarla.</p>';});
