<script setup>
import MiniStatisticsCard from "@/examples/Cards/MiniStatisticsCard.vue";
import GradientLineChart from "@/examples/Charts/GradientLineChart.vue";
import Carousel from "./components/Carousel.vue";
</script>
<template>
  <div class="py-4 container-fluid">
    <div class="row">
      <div class="col-lg-12">
        <div class="row">
          <div class="col-lg-3 col-md-6 col-12">
            <mini-statistics-card
              title="My task"
              value="5"
              description="<span
                class='text-sm font-weight-bolder text-success'
                >+50%</span> since yesterday"
              :icon="{
                component: 'fa fa-tasks',
                background: 'bg-gradient-primary',
                shape: 'rounded-circle',
              }"
            />
          </div>
          <div class="col-lg-3 col-md-6 col-12">
            <mini-statistics-card
              title="contributed document"
              value="2,300"
              description="<span
                class='text-sm font-weight-bolder text-success'
                >+3%</span> since last week"
              :icon="{
                component: 'fa fa-folder',
                background: 'bg-gradient-danger',
                shape: 'rounded-circle',
              }"
            />
          </div>
          <div class="col-lg-3 col-md-6 col-12">
            <mini-statistics-card
              title="Document for approuving"
              value="+3"
              description="<span
                class='text-sm font-weight-bolder text-danger'
                >-2%</span> since last quarter"
              :icon="{
                component: 'fa fa-file-word-o',
                background: 'bg-gradient-success',
                shape: 'rounded-circle',
              }"
            />
          </div>
          <div class="col-lg-3 col-md-6 col-12">
            <mini-statistics-card
              title="Document for reading"
              value="3"
              description="<span
                class='text-sm font-weight-bolder text-success'
                >+5%</span> than last month"
              :icon="{
                component: 'fa fa-file-pdf-o',
                background: 'bg-gradient-warning',
                shape: 'rounded-circle',
              }"
            />
          </div>
        </div>
        <div class="row">
          <div class="col-lg-7 mb-lg">
            <!-- line chart -->
            <div class="card z-index-2">
              <gradient-line-chart
                id="chart-line"
                title="Use Overview"
                description="<i class='fa fa-arrow-up text-success'></i>
      <span class='font-weight-bold'>4% more</span> in 2021"
                :chart="{
                  labels: [
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ],
                  datasets: [
                    {
                      label: 'Mobile Apps',
                      data: [50, 40, 300, 220, 500, 250, 400, 230, 500],
                    },
                  ],
                }"
              />
            </div>
          </div>
          <div class="col-lg-5">
            <carousel>
              <div class="carousel-inner">
                <div class="carousel-item active">
                  <img
                    class="d-block w-100"
                    src="https://www.google.com/search?q=add+document&tbm=isch&ved=2ahUKEwjtgIeF_6GFAxUmVKQEHd-tCxIQ2-cCegQIABAA&oq=add+document&gs_lp=EgNpbWciDGFkZCBkb2N1bWVudDIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIHEAAYgAQYEzIIEAAYBRgeGBMyCBAAGAUYHhgTSIZMUNALWI9DcAF4AJABAJgBwwKgAbMVqgEIMC4xMC4zLjG4AQPIAQD4AQGKAgtnd3Mtd2l6LWltZ6gCCsICBBAjGCfCAggQABgHGB4YE8ICCBAAGAgYHhgTwgIFEAAYgATCAggQABiABBixA8ICCxAAGIAEGLEDGIMBwgIHECMY6gIYJ8ICDhAAGIAEGIoFGLEDGIMBwgIEEAAYA8ICChAAGIAEGIoFGEPCAgQQABgeiAYB&sclient=img&ei=gisLZu23BaaokdUP39uukAE&bih=738&biw=1536&prmd=isvnbz&rlz=1C1ONGR_frTN1078TN1078#imgrc=jPl4BpAHFPhxAM"
                    alt="First slide"
                  />
                </div>
                <div class="carousel-item">
                  <img
                    class="d-block w-100"
                    src="https://www.google.com/search?q=update&ved=2ahUKEwjFjqDm_6GFAxVzUqQEHRh3BK4Q2-cCegQIABAA&oq=update&gs_lp=EgNpbWciBnVwZGF0ZTIEECMYJzIFEAAYgAQyChAAGIAEGIoFGEMyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAESOQhUIQHWPwdcAF4AJABAJgBwQGgAewLqgEDMC45uAEDyAEA-AEBigILZ3dzLXdpei1pbWeoAgrCAgcQIxjqAhgnwgIIEAAYgAQYsQPCAgsQABiABBixAxiDAYgGAQ&sclient=img&ei=TSwLZoW0OPOkkdUPmO6R8Ao&bih=738&biw=1536&prmd=isvnbz&rlz=1C1ONGR_frTN1078TN1078&udm=2#vhid=jvQUmxmhoPYiOM&vssid=mosaic"
                    alt="Second slide"
                  />
                </div>
                <div class="carousel-item">
                  <img
                    class="d-block w-100"
                    src="https://www.google.com/search?q=share&sca_esv=d66abf2c052447ae&bih=738&biw=1536&rlz=1C1ONGR_frTN1078TN1078&udm=2&sxsrf=ACQVn0_PYZWPF10ch0h1Fr92nqIW0aWdlw%3A1712008285801&ei=XSwLZu_AMKCYkdUP3aacyAc&ved=0ahUKEwiv4-jt_6GFAxUgTKQEHV0TB3kQ4dUDCBA&uact=5&oq=share&gs_lp=Egxnd3Mtd2l6LXNlcnAiBXNoYXJlMgoQABiABBiKBRhDMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAESI0iUPUDWMMacAJ4AJABBJgBwQKgAcQOqgEHMC44LjEuMbgBA8gBAPgBAZgCCKACuQmoAgrCAgQQIxgnwgIHECMY6gIYJ8ICCBAAGIAEGLEDmAMGiAYBkgcHMi40LjEuMaAHxjs&sclient=gws-wiz-serp#vhid=8euyz2HuhCSn7M&vssid=mosaic"
                    alt="Third slide"
                  />
                </div>
              </div>
            </carousel>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
