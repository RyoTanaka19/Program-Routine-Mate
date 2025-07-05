// tailwind.config.js

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      keyframes: {
        glow: {
          '0%, 100%': {
            boxShadow: '0 0 8px #22c55e',
            color: '#22c55e',
          },
          '50%': {
            boxShadow: '0 0 16px #22c55e',
            color: '#22c55e',
          },
        },
      },
      animation: {
        'glow-animation': 'glow 1.5s ease-in-out infinite',
      },
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    darkTheme: false,
  },
};
