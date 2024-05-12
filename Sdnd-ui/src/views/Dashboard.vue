<template>
  <div class="py-4 container-fluid">

    <div class="row">

      <div class="col-lg-12">
        <div class="row">
          
          <div class="col-lg-3 col-md-6 col-12" v-if="documentStatistics && documentStatistics.documentsByState">
            <mini-statistics-card v-for="(statistic, index) in documentStatistics.documentsByState"
              :key="'state-' + index" :title="getStateName(statistic.state) + ' Document '" :value="statistic.count"
              description=""
              :icon="{ component: 'fa-solid fa-check', background: 'bg-gradient-primary', shape: 'rounded-circle' }" />
          </div>

          <div class="col-lg-3 col-md-6 col-12" v-if="documentStatistics && documentStatistics.totalDocuments">
            <mini-statistics-card :title="'Total Documents'" :value="documentStatistics.totalDocuments" description=""
              :icon="{ component: 'fa fa-folder', background: 'bg-gradient-warning', shape: 'rounded-circle' }" />
          </div>
          <div class="col-lg-3 col-md-6 col-12" v-if="filesCount">
            <mini-statistics-card :title="'Total Files'" :value="filesCount" description=""
              :icon="{ component: 'fa fa-file', background: 'bg-gradient-info', shape: 'rounded-circle' }" />
          </div>
          <div class="col-lg-3 col-md-6 col-12" v-if="usersCount !== null && usersCount !== undefined">
  <mini-statistics-card :title="'Total Users'" :value="usersCount" description=""
    :icon="{ component: 'fa fa-user', background: 'bg-gradient-danger', shape: 'rounded-circle' }" />
</div>


        </div>
      </div>
    </div>

    <div class="row mt-4 justify-content-center">
      <div class="col-lg-8">
        <div class="card">
          <div class="card-body">
            <canvas id="documentUploadChart" class="chart-canvas"></canvas>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import MiniStatisticsCard from "@/examples/Cards/MiniStatisticsCard.vue";
import { ref, onMounted } from 'vue';
import BaseApiService from "../services/apiService";
import Chart from 'chart.js/auto';

const documentStatistics = ref(null);
const filesCount = ref(null);
const usersCount = ref(null)
const documentUploadStats = ref(null);
const fetchDocumentStatistics = async () => {
  try {
    const response = await BaseApiService('Document/statistics').list();
    console.log('Document statistics response:', response.data);
    documentStatistics.value = response.data;
  } catch (error) {
    console.error('Error fetching document statistics:', error);
  }
};



const fetchFilesCount = async () => {
  try {
    const response = await BaseApiService('File/files/total-count').list();
    console.log('Files total:', response.data);
    filesCount.value = response.data;
  } catch (error) {
    console.error('Error fetching files total:', error);
  }
};
const fetchUsersCount = async () => {
  try {
    const response = await BaseApiService('Account/users/total-count').list();
    console.log('Users total:', response.data);
    usersCount.value = response.data;
  } catch (error) {
    console.error('Error fetching users total:', error);
  }
};
const fetchDocumentUploadStatistics = async () => {
  try {
    const response = await BaseApiService('Document/added-document-stats').list();
    console.log('Document upload stats response:', response.data);
    documentUploadStats.value = response.data; 
    renderChart(); 
  } catch (error) {
    console.error('Error fetching document upload stats:', error);
  }
};

const renderChart = () => {
  if (!documentUploadStats.value) {
    console.error('Document upload stats is null');
    return;
  }

  const canvas = document.getElementById('documentUploadChart');
  if (!canvas) {
    console.error('Canvas element not found');
    return;
  }

  const ctx = canvas.getContext('2d');
  if (!ctx) {
    console.error('Failed to get canvas context');
    return;
  }

  const chartData = {
    labels: documentUploadStats.value.monthNames,
    datasets: [
      {
        label: 'Monthly Document Uploads',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        borderColor: 'rgba(75, 192, 192, 1)',
        data: documentUploadStats.value.monthlyDocumentUploadsTable.map(val => Math.round(val)), // Round the values to integers
      },
    ],
  };

  const chartOptions = {
    scales: {
      y: {
        beginAtZero: true,
        ticks: {
          precision: 0, // Display integers only
        },
      },
    },
    responsive: true,
    maintainAspectRatio: false,
  };

  new Chart(ctx, {
    type: 'line',
    data: chartData,
    options: chartOptions,
  });
};
const stateNames = {
  0: 'Blank',
  1: 'Filled',
  2: 'Shared',
  3: 'Archived'
};

const getStateName = (stateNumber) => {
  return stateNames[stateNumber] || 'Unknown';
};

onMounted(async () => {
  fetchDocumentStatistics();
  fetchFilesCount();
  fetchUsersCount();
  fetchDocumentUploadStatistics();
});
</script>

<style scoped>
.chart-canvas {
  width: 100%;
  height: 400px;
}
</style>
