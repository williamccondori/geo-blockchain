<template>
  <section>
    <h1 class="mb-1">SISTEMA INTEGRADO DE CATASTRO</h1>
    <el-divider />
    <el-card>
      <div id="map" />
    </el-card>
  </section>
</template>

<script>
import L from "leaflet";
import "leaflet/dist/leaflet.css";

export default {
  name: "IndexPage",
  mounted() {
    this.initMap();
  },
  methods: {
    initMap() {
      const map = L.map("map").setView([-0.23, -78.5], 13);
      // Add base map.
      map.addLayer(
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
          attribution: "&copy; WILLIAM CONDORI QUISPE",
        })
      );
    },
  },
};
</script>
