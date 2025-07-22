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
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
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
        slideOutRight: {
          '0%': { opacity: '1', transform: 'translateX(0)' },
          '100%': { opacity: '0', transform: 'translateX(100%)' },
        },
      },
      animation: {
        'fade-in': 'fadeIn 0.8s ease-out forwards',
        'glow-animation': 'glow 1.5s ease-in-out infinite',
        'slide-out-right': 'slideOutRight 0.5s forwards',
      },
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    darkTheme: false,
  },
};
