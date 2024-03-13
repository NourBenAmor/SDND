<script setup>
import { onBeforeUnmount, onBeforeMount } from "vue";
import { useStore } from "vuex";
import { ref } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import Navbar from "@/examples/PageLayout/Navbar.vue";
import AppFooter from "@/examples/PageLayout/Footer.vue";
import ArgonInput from "@/components/ArgonInput.vue";
import ArgonCheckbox from "@/components/ArgonCheckbox.vue";
import ArgonButton from "@/components/ArgonButton.vue";
const body = document.getElementsByTagName("body")[0];
const router = useRouter();


const registerForm = ref({
  username: '',
  email: '',
  password: ''
});

const registerUser = async () => {
  try {
    const response = await axios.post('https://localhost:7278/api/Account/register', {
      Username: registerForm.value.username,
      Email: registerForm.value.email,
      Password: registerForm.value.password
    });
    console.log('Registration successful:', response.data);
    router.push('/dashboard-default');
  } catch (error) {
    console.error('Registration failed:', error.response.data);
  }
};

const handleSubmit = async () => {
  await registerUser();
};
const store = useStore();
onBeforeMount(() => {
  store.state.hideConfigButton = true;
  store.state.showNavbar = false;
  store.state.showSidenav = false;
  store.state.showFooter = false;
  body.classList.remove("bg-gray-100");
});
onBeforeUnmount(() => {
  store.state.hideConfigButton = false;
  store.state.showNavbar = true;
  store.state.showSidenav = true;
  store.state.showFooter = true;
  body.classList.add("bg-gray-100");
});
</script>
<template>
  <div class="container top-0 position-sticky z-index-sticky">
    <div class="row">
      <div class="col-12">
        <navbar isBtn="bg-gradient-light" />
      </div>
    </div>
  </div>
  <main class="main-content mt-0">
    <div
      class="page-header align-items-start min-vh-50 pt-5 pb-11 m-3 border-radius-lg"
      
    >
      <span class="mask bg-gradient-dark opacity-6"></span>
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-5 text-center mx-auto">
            <h1 class="text-white mb-2 mt-5">Welcome!</h1>
            <p class="text-lead text-white">
              Use these awesome forms to login or create new account in your
              project for free.
            </p>
          </div>
        </div>
      </div>
    </div>
    <div class="container">
        <div class="row mt-lg-n10 mt-md-n11 mt-n10 justify-content-center">
          <div class="col-xl-4 col-lg-5 col-md-7 mx-auto">
            <div class="card z-index-0">
              <div class="card-header text-center pt-4">
                <h5>Register with</h5>
              </div>
              <div class="row px-xl-5 px-sm-4 px-3">
                <div class="col-12">
                  <form @submit.prevent="handleSubmit">
                    <ArgonInput
                      id="name"
                      type="text"
                      placeholder="Name"
                      aria-label="Name"
                      v-model="registerForm.username"
                    />
                    <ArgonInput
                      id="email"
                      type="email"
                      placeholder="Email"
                      aria-label="Email"
                      v-model="registerForm.email"
                    />
                    <ArgonInput
                      id="password"
                      type="password"
                      placeholder="Password"
                      aria-label="Password"
                      v-model="registerForm.password"
                    />
                    <ArgonCheckbox checked>
                      <label class="form-check-label" for="flexCheckDefault">
                        I agree the
                        <a href="javascript:;" class="text-dark font-weight-bolder"
                          >Terms and Conditions</a
                        >
                      </label>
                    </ArgonCheckbox>
                    <div class="text-center">
                      <ArgonButton
                        fullWidth
                        color="dark"
                        variant="gradient"
                        class="my-4 mb-2"
                        type="submit"
                      >
                        Sign up
                      </ArgonButton>
                    </div>
                    <!-- Sign in link -->
                    <p class="text-sm mt-3 mb-0">
                      Already have an account?
                      <a href="javascript:;" class="text-dark font-weight-bolder"
                        >Sign in</a
                      >
                    </p>
                  </form>
                  </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
  <app-footer />
</template>
