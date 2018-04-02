class Tipfy {
  constructor(selector){
    document.querySelectorAll(selector).forEach( item => {
      if(item.hasAttribute('title')){
        const title = item.getAttribute('title');
        item.dataset.tipfy = title;
        item.removeAttribute('title');
        item.setAttribute('aria-label', title);
      }
    })
    document.addEventListener('mouseover', e => {
      const tag = e.target;
      if(tag.hasAttribute('data-tipfy')){
        this.build(tag);
      }
    });
  }
  build(tag){
    const tipfy = tag.dataset.tipfy,
    rect = tag.getBoundingClientRect();
    document.body.insertAdjacentHTML('beforeend', `<div class="tipfy__wrap"><div class="tipfy__main">${tipfy}</div></div>`);
    const wrap = document.querySelector('.tipfy__wrap'),
    classCustom = tag.dataset.tipfyClass;
    try{
      if(document.querySelector(tipfy) && !tag.hasAttribute('data-tipfy-text')){
        const html = document.querySelector(tipfy).outerHTML;
        wrap.children[0].innerHTML = html;
      }
    } catch(e){}

    if(classCustom){
      classCustom.split(' ').forEach( item => {
        wrap.children[0].classList.add(item);
      })
    }

    this.side(tag, rect, wrap);
    this.remove(tag);
  }
  side(tag, rect, wrap){
    const wrapRect = wrap.getBoundingClientRect(),
    top = window.scrollY,
    left = window.scrollX,
    tipSide = tag.dataset.tipfySide||'top',
    position = {
      right: () => {
        wrap.setAttribute('style', `left: ${rect.right + left}px;top: ${rect.top + rect.height/2 + top}px;width: ${wrapRect.width}px;`);
        wrap.children[0].classList.add('tipfy__side-right');
      }
      , left: () => {
        wrap.setAttribute('style', `left: ${rect.left + left - wrapRect.width}px;top: ${rect.top + rect.height/2 + top}px;width: ${wrapRect.width}px;`);
        wrap.children[0].classList.add('tipfy__side-left');
      }
      , bottom: () => {
        wrap.setAttribute('style', `left: ${rect.left + left - wrapRect.width/2 + rect.width/2}px;top: ${rect.bottom + top}px;height: ${wrapRect.height}px;width: ${wrapRect.width}px;`);
        wrap.children[0].classList.add('tipfy__side-bottom');
      }
      , top: () => {
        wrap.setAttribute('style', `left: ${rect.left + left - wrapRect.width/2 + rect.width/2}px;top: ${rect.top - wrapRect.height + top}px;height: ${wrapRect.height}px;width: ${wrapRect.width}px;`);
        wrap.children[0].classList.add('tipfy__side-top');
      }
    }
    position[tipSide]();
  }
  remove(tag){
    tag.addEventListener('mouseout', event => {
      document.querySelectorAll('.tipfy__wrap').forEach(item => {
        item.remove();
      });
    }, {
      once: true
    });
  }
}