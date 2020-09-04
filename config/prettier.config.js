// prettier.config.js or .prettierrc.js
module.exports = {
    printWidth: 100,
    // tabWidth: 4, // inherits from .editorconfig
    trailingComma: 'es5',
    singleQuote: true,
    overrides: [
        {
            files: '*.cmp',
            options: {
                printWidth: 160,
                tabWidth: 2,
            },
        },
        {
            files: 'src/**/lwc/**/*.html',
            options: {
                parser: 'lwc',
                printWidth: 80,
                tabWidth: 2,
            },
        },
    ],
};
