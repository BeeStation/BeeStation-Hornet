export const authMiddleware = (store) => {
  return (next) => (action) => {
    const { type, payload } = action;
    if (type === 'auth/store') {
      if (!Byond.TRIDENT && window.domainStorage && !!window.domainStorage.getItem) {
        window.domainStorage.setItem('session_token', payload);
      } else {
        localStorage.setItem('session_token', payload);
      }
      return;
    } else if (type === 'auth/login') {
      let token;
      if (!Byond.TRIDENT && window.domainStorage && !!window.domainStorage.getItem) {
        token = window.domainStorage.getItem('session_token');
      } else {
        token = localStorage.getItem('session_token');
      }
      if (typeof token === 'string' && token.length > 0 && token.length <= 128) {
        Byond.topic({ session_token: token });
      }
      return;
    }
    return next(action);
  };
};
