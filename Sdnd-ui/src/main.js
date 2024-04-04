import { createApp } from "vue";
import App from "./App.vue";
import store from "./store";
import router from "./router";
import "./assets/css/nucleo-icons.css";
import Vue3Toasity from "vue3-toastify";
import "vue3-toastify/dist/index.css";
import "./assets/css/nucleo-svg.css";
import ArgonDashboard from "./argon-dashboard";
const appInstance = createApp(App);
appInstance.use(Vue3Toasity, {
  autoClose: 3000,
});
appInstance.use(store);
appInstance.use(router);
appInstance.use(ArgonDashboard);
appInstance.mount("#app");
