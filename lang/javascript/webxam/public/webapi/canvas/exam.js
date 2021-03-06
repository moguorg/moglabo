/**
 * @fileOverview Canvas調査用スクリプト
 */

const loadTestBlob = async () => {
  const response = await fetch('/webxam/service/loadTestImage');
  if (response.ok) {
    return await response.blob();
  } else {
    throw new Error(`Cannot load image: ${response.statusText}`);
  }
};

const toBitmapImage = image => {
  const offscreen = new OffscreenCanvas(image.width, image.height);
  const context = offscreen.getContext('2d');
  context.drawImage(image, 0, 0);
  const bitmap = offscreen.transferToImageBitmap();
  return bitmap;
};

const getRandomRGB = () => {
  return [
    parseInt(Math.random() * 255),
    parseInt(Math.random() * 255),
    parseInt(Math.random() * 255)
  ];
};

const getRandomRGBA = () => {
  const values = getRandomRGB();
  values.push(Math.random().toFixed(1));
  return values;
};

// BlobURLを引数に取ることでもWorkerを生成することはできる。
const createDrawWorkerURL = async () => {
  const response = await fetch(`drawworker.js`);
  if (response.ok) {
    const blob = await response.blob();
    return URL.createObjectURL(blob);
  } else {
    throw new Error(`Cannot create worker: ${response.statusText}`);
  }
};

// DOM

const blobToImage = blob => {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(blob);
    const img = new Image();
    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = reject;
    img.src = url;
  });
};

const fitCanvasSize = canvas => {
  const style = getComputedStyle(canvas);
  // canvas要素のサイズを設定しないと描画された図形が意図したサイズと異なってしまう。
  canvas.width = parseInt(style.getPropertyValue('width'));
  canvas.height = parseInt(style.getPropertyValue('height'));
};

let drawWorkers = [];

const listeners = {
  /**
   * OffscreenCanvasやサーバリクエストは全く不要だが振る舞いの調査のため行っている。
   */
  async transferToImageBitmap(root) {
    try {
      const blob = await loadTestBlob();
      const url = URL.createObjectURL(blob);
      const image = new Image();
      image.onload = () => {
        URL.revokeObjectURL(url);
        const bitmap = toBitmapImage(image);
        const canvas = root.querySelector('.output');
        canvas.getContext('bitmaprenderer').transferFromImageBitmap(bitmap);
      };
      image.src = url;
    } catch (err) {
      alert(err.message);
      throw err;
    }
  },
  async convertToBlob(root) {
    const canvas = new OffscreenCanvas(300, 300);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = 'red';
    ctx.fillRect(canvas.width / 2, canvas.height / 2, 100, 80);
    const blob = await canvas.convertToBlob();
    const url = URL.createObjectURL(blob);
    const img = new Image();
    img.onload = () => {
      URL.revokeObjectURL(url);
      const output = root.querySelector('.output');
      output.innerHTML = '';
      output.appendChild(img);
    };
    img.src = url;
  },
  async transferControlToOffscreen(root) {
    if (drawWorkers.length > 0) {
      this.stopControlToOffscreen(root);
    }
    const canvas = root.querySelector('.output');
    fitCanvasSize(canvas);
    const array = new Array(parseInt(root.querySelector('.workersize').value));
    const url = await createDrawWorkerURL();
    drawWorkers = array.fill(url, 0, array.length).map(url => {
      // 同じ名前のファイルからはどうしても1つしかWorkerが生成できない？
      // blobURLでWorkerを生成した場合はたとえどれも同じBlobURLだったとしても
      // newした数だけWorkerを生成できているようである。
      const worker = new Worker(url);
      worker.url = url;
      const offscreen = canvas.cloneNode(true).transferControlToOffscreen();
      const fillStyle = `rgba(${getRandomRGBA().join(',')})`;
      const context = canvas.getContext('bitmaprenderer');
      // 第2引数でOffscreenCanvasを渡さないとエラーになる。
      worker.postMessage({canvas: offscreen, fillStyle}, [offscreen]);
      worker.onmessage = event =>
        context.transferFromImageBitmap(event.data);
      return worker;
    });
  },
  stopControlToOffscreen(root) {
    drawWorkers.forEach(worker => {
      worker.terminate();
      URL.revokeObjectURL(worker.url);
    });
    drawWorkers = [];
  }
};

const inits = {
};

const addListener = () => {
  Array.from(document.querySelectorAll('.example')).forEach(el => {
    el.addEventListener('pointerup', async event => {
      const root = event.target.dataset.eventTarget;
      if (root) {
        event.stopPropagation();
        await listeners[root](el);
      }
    });
  });
};

window.addEventListener('DOMContentLoaded', () => {
  addListener();
  Object.values(inits).forEach(f => f());
});