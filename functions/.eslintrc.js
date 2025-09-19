module.exports = {
  "env": {
    "es6": true,
    "node": true,
  },
  "extends": [
    "eslint:recommended",
    "google",
  ],
  "parserOptions": {
    "ecmaVersion": 2020,
  },
  "rules": {
    "quotes": ["error", "double"],
    "max-len": "off", // Отключаем проверку длины строки
    "linebreak-style": "off", // Отключаем проверку символов конца строки
    "require-jsdoc": "off", // Отключаем требование JSDoc комментариев
    "indent": "off", // Отключаем проверку отступов
  },
};

