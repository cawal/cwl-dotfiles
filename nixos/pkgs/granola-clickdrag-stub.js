// Stub no-op para electron-click-drag-plugin. O .node prebuilt do bundle
// segfaulta no dlopen e o main-process da Granola o exige incondicionalmente no
// startup (sem tratar erro), derrubando o app. Este Proxy resolve todo acesso/
// chamada para uma função vazia, então a convenção de chamada que a Granola usar
// simplesmente não faz nada. Ver nixos/pkgs/granola.nix.
function makeStub() {
  const noop = () => {};
  const handler = {
    get(_target, prop) {
      if (prop === '__esModule') return false;
      if (prop === 'default') return proxy;
      if (prop === 'then') return undefined;
      return noop;
    },
    apply() { return undefined; },
  };
  const proxy = new Proxy(noop, handler);
  return proxy;
}
module.exports = makeStub();
