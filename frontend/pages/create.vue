<template>
  <section>
    <h1 class="mb-1">CREACIÓN DE POLÍGONOS</h1>
    <el-divider />
    <el-card class="mb-1">
      <h1 class="mb-1">POLÍGONOS TEMPORALES</h1>
      <el-table :data="temporalLayers" style="width: 100%" size="mini">
        <el-table-column prop="id" label="CÓDIGO" />
        <el-table-column prop="creationDate" label="FECHA DE CREACIÓN" />
        <el-table-column align="right">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="handleCreate(scope.row.id)"
            >
              <span>GUARDAR</span>
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-card>
      <div id="map"></div>
    </el-card>
    <el-drawer
      :visible="createVisible"
      @close="handleClose"
      title="GUARDAR POLÍGONO"
    >
      <el-main>
        <el-form ref="formRef" :model="form" :rules="formRules">
          <el-form-item label="NOMBRE:" prop="name">
            <el-input type="name" v-model="form.name"></el-input>
          </el-form-item>
          <el-form-item label="APELLIDO:" prop="lastName">
            <el-input type="lastName" v-model="form.lastName"></el-input>
          </el-form-item>
          <el-form-item label="N° DE CONTRATO:" prop="contractNumber">
            <el-input
              type="contractNumber"
              v-model="form.contractNumber"
            ></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="success" @click="handleSubmit" class="block">
              GUARDAR
            </el-button>
          </el-form-item>
        </el-form>
      </el-main>
    </el-drawer>
  </section>
</template>

<script>
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import "leaflet-draw/dist/leaflet.draw.css";
import "leaflet-draw/dist/leaflet.draw.js";

import { v4 as uuidv4 } from "uuid";

const form = {
  name: "",
  lastName: "",
  contractNumber: "",
};

const formRules = {
  name: [{ required: true, message: "INGRESE SU NOMBRE" }],
  lastName: [{ required: true, message: "INGRESE SU APELLIDO" }],
  contractNumber: [{ required: true, message: "INGRESE SU N° DE CONTRATO" }],
};

export default {
  data() {
    return {
      form,
      formRules,
      map: null,
      temporalLayers: [],
      createVisible: false,
    };
  },
  mounted() {
    this.initMap();
  },
  methods: {
    initMap() {
      const map = L.map("map").setView([-0.23, -78.5], 13);

      const editableLayer = new L.FeatureGroup();
      map.addLayer(editableLayer);

      new L.Control.Draw({
        draw: {
          circle: false,
          marker: false,
          polyline: false,
          rectangle: false,
          circlemarker: false,
        },
        edit: {
          featureGroup: editableLayer,
          remove: true,
        },
      }).addTo(map);

      map.on("draw:created", ({ layer }) => {
        editableLayer.addLayer(layer);
        this.temporalLayers.push({
          id: layer._leaflet_id,
          creationDate: new Date().toISOString(),
        });
      });

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: "&copy; WILLIAM CONDORI QUISPE",
      }).addTo(map);

      L.control.scale().addTo(map);

      this.map = map;
    },
    handleCreate(leafletId) {
      this.createVisible = true;
    },
    handleClose() {
      this.createVisible = false;
    },
    handleSubmit() {
      this.$refs.formRef.validate((valid) => {
        if (valid) {
        }
      });
    },
  },
};
</script>

<style scoped>
#map {
  height: calc(100vh - 20rem);
}
</style>
