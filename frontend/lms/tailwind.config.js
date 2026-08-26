/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: '#002855',
        'navy-deep': '#001a35',
        'navy-light': '#1a3a6b',
      },
    },
  },
  plugins: [],
}
