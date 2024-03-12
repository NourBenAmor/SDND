import { createApp } from "vue";
import App from "./App.vue";
import store from "./store";
import router from "./router";
import "./assets/css/nucleo-icons.css";
import { VueQueryPlugin } from "@tanstack/vue-query";

import "./assets/css/nucleo-svg.css";
import ArgonDashboard from "./argon-dashboard";

const appInstance = createApp(App);
appInstance.use(store);
appInstance.use(VueQueryPlugin);
appInstance.use(router);
appInstance.use(ArgonDashboard);
appInstance.mount("#app");
