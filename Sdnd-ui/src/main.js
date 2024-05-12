import { createApp } from "vue";
import App from "./App.vue";
import store from "./store";
import router from "./router";
import "./assets/css/nucleo-icons.css";
import Vue3Toasity from "vue3-toastify";
import "vue3-toastify/dist/index.css";
import "./assets/css/nucleo-svg.css";
import Vue3Signature from "vue3-signature";
import ArgonDashboard from "./argon-dashboard";
import PrimeVue from "primevue/config";
import Tooltip from "primevue/tooltip";
//in main.js
import "primevue/resources/themes/aura-light-indigo/theme.css";
const appInstance = createApp(App);
appInstance.use(Vue3Toasity, {
  autoClose: 3000,
  clearOnUrlChange: false,
});
appInstance.use(Vue3Signature);
appInstance.use(store);
appInstance.use(PrimeVue, {
  zIndex: {
    modal: 100001, //dialog, sidebar
    overlay: 130002, //dropdown, overlaypanel
    menu: 100003, //overlay menus
    tooltip: 110000, //tooltip
  },
});
appInstance.directive("tooltip", Tooltip), appInstance.use(router);
appInstance.use(ArgonDashboard);
appInstance.mount("#app");
