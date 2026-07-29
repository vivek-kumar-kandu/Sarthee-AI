import js from "@eslint/js";


export default [

  // ============================================================================
  // IGNORED FILES
  // ============================================================================

  {
    ignores: [
      "node_modules/**",
      "logs/**",
      "coverage/**",
      "dist/**",
      "build/**",
    ],
  },


  // ============================================================================
  // ESLINT RECOMMENDED RULES
  // ============================================================================

  js.configs.recommended,


  // ============================================================================
  // PROJECT CONFIGURATION
  // ============================================================================

  {
    files: [
      "**/*.js",
    ],


    languageOptions: {

      ecmaVersion: "latest",

      sourceType: "module",


      globals: {

        // Node.js
        process: "readonly",
        Buffer: "readonly",


        // Console logging
        console: "readonly",


        // Timers
        setTimeout: "readonly",
        clearTimeout: "readonly",
        setInterval: "readonly",
        clearInterval: "readonly",

      },

    },


    rules: {


      // ==========================================================================
      // CODE STYLE
      // ==========================================================================


      // Double quotes project standard
      quotes: [
        "error",
        "double",
        {
          avoidEscape: true,
        },
      ],


      // Semicolons required
      semi: [
        "error",
        "always",
      ],


      // ==========================================================================
      // FORMATTING
      // ==========================================================================
      //
      // Formatting handled by Prettier.
      // ESLint should not fight with Prettier.
      //

      indent: "off",



      // ==========================================================================
      // VARIABLES
      // ==========================================================================


      "no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
        },
      ],



      // ==========================================================================
      // SAFETY RULES
      // ==========================================================================


      "no-console": "off",


      "no-undef": "error",


      "no-unreachable": "error",


      "no-duplicate-imports": "error",



      // ==========================================================================
      // JAVASCRIPT QUALITY
      // ==========================================================================


      eqeqeq: [
        "error",
        "always",
      ],


      curly: [
        "error",
        "all",
      ],


      "object-shorthand": [
        "error",
        "always",
      ],


    },

  },

];