<template>
  <section>
    <div class="text-center">
      <img src="~/assets/images/logo.png" alt="logo" class="logo" />
    </div>
    <el-alert
      title="¡BIENVENIDO!"
      type="success"
      description="CON GEO BLOCKCHAIN, PUEDES CREAR Y MODIFICAR TU INFORMACIÓN GEOESPACIAL EN LÍNEA."
      show-icon
      class="mb-1"
    />
    <el-card>
      <div id="map" />
    </el-card>
  </section>
</template>

<script>
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import moment from "moment";

export default {
  name: "IndexPage",
  data() {
    return {
      // Blockchain
      account: null,
      registersContract: {},
    };
  },
  async mounted() {
    await this.initDApp();
    if (!this.map) {
      await this.initMap();
    }
  },
  methods: {
    async initMap() {
      const map = L.map("map").setView([-12.5811764, -69.1565787], 12);
      // Add base map.
      const baseLayer = L.tileLayer(
        "https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png"
      );
      map.addLayer(baseLayer);

      const baseLayers = {
        "STADIA.OSMBRIGHT": baseLayer,
        "STADIA.ALIDADESMOOTHDARK": L.tileLayer(
          "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"
        ),
        "STADIA.ALIDADESMOOTH": L.tileLayer(
          "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png"
        ),
        "GOOGLE.MAPS": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=r&x={x}&y={y}&z={z}"
        ),
        "GOOGLE.HYBRID": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}"
        ),
        "GOOGLE.ROADS": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=h&x={x}&y={y}&z={z}"
        ),
      };

      // Add regions layer.
      let response = await fetch("Departamentos.geojson");
      let responseGeojson = await response.json();
      const regionLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "lightblue",
          weight: 1,
          fillColor: "lightblue",
          fillOpacity: 0.05,
        },
      });

      // Add district layer.
      response = await fetch("Provincias.geojson");
      responseGeojson = await response.json();
      const provinceLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "green",
          weight: 1,
          fillColor: "green",
          fillOpacity: 0.05,
        },
      });

      // Add district layer.
      response = await fetch("Distritos.geojson");
      responseGeojson = await response.json();
      const districtLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "orange",
          weight: 1,
          fillColor: "orange",
          fillOpacity: 0.05,
        },
      });

      const overlayMaps = {
        DEPARTAMENTOS: regionLayer,
        PROVINCIAS: provinceLayer,
        DISTRITOS: districtLayer,
      };
      L.control.layers(baseLayers, overlayMaps).addTo(map);

      const rCounter = await this.registersContract.registerCounter();
      const registerCounter = rCounter.toNumber();
      for (let i = 1; i <= registerCounter; i++) {
        const register = await this.registersContract.registers(i);
        let geojson = register[4];
        geojson = JSON.parse(geojson);
        const geojsonLayer = L.geoJSON(geojson, {
          style: {
            color: "purple",
            weight: 3,
          },
          zIndex: 100,
        });
        geojsonLayer.bindPopup(
          `
          <table class="table">
            <tbody>
              <tr>
                <th scope="row">N° DE CONTRATO</th>
                <td>${register[3]}</td>
              </tr>
              <tr>
                <th scope="row">NOMBRE</th>
                <td>${register[1]}</td>
              </tr>
              <tr>
                <th scope="row">APPELLIDO</th>
                <td>${register[2]}</td>
              </tr>
              <tr>
                <th scope="row">FECHA DE CREACIÓN:</th>
                <td>${moment(new Date(register[5] * 1000)).format(
                  "DD/MM/YYYY hh:mm"
                )}</td>
              </tr>
              <tr>
                <th scope="row">MODIFICADO POR:</th>
                <td>${register[6]}</td>
              </tr>
            </tbody>
          </table>
          `
        );
        map.addLayer(geojsonLayer);
      }
    },
    async initDApp() {
      if (window.ethereum) {
        // Accessing the provider through the ethereum object.
        const web3Provider = window.ethereum;
        const accounts = await web3Provider.request({
          method: "eth_requestAccounts",
        });
        this.account = accounts[0];
        // Load contract.
        const contracts = {};
        const response = await fetch("/RegistersContract.json");
        // eslint-disable-next-line no-undef
        contracts.RegistersContract = TruffleContract(await response.json());
        contracts.RegistersContract.setProvider(web3Provider);
        this.registersContract = await contracts.RegistersContract.deployed();
      } else {
        this.$message.error(
          "NO SE HA ENCONTRADO LA EXTENSIÓN METAMASK, INSTALALA PARA PODER USAR LA APLICACIÓN"
        );
      }
    },
  },
};
</script>

<style scoped>
.logo {
  width: 20rem;
}
</style>
