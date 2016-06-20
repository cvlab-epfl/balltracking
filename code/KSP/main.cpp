/************************************************************************/
/* (c) 2009-2011 Ecole Polytechnique Federale de Lausanne               */
/* All rights reserved.                                                 */
/*                                                                      */
/* EPFL grants a non-exclusive and non-transferable license for non     */
/* commercial use of the Software for education and research purposes   */
/* only. Any other use of the Software is expressly excluded.           */
/*                                                                      */
/* Redistribution of the Software in source and binary forms, with or   */
/* without modification, is not permitted.                              */
/*                                                                      */
/* Written by Engin Turetken and Jerome Berclaz.                        */
/*                                                                      */
/* http://cvlab.epfl.ch/research/body/surv                              */
/* Contact <pom@epfl.ch> for comments & bug reports.                    */
/************************************************************************/

#include <getopt.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <vector>
#include "global.h"
#include "ksp_graph.h"
#include "ksp_computer.h"

#include <sstream>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <stdlib.h>
#include <string>
#include <stdio.h>
#include <math.h>
#include <fstream>


using namespace std;

static struct option long_options[] = {
  {"help", 0, 0, 'h'},
  {"output", 1, 0, 'o'},
  {"shortest", 1, 0, 's'},
  {"pom-prior", 1, 0, 'p'},
  {"min-prob", 1, 0, 'l'},
  {"max-prob", 1, 0, 'u'},
  {0, 0, 0, 0}
};

static const char *explanation[] = {
  "display help",
  "output file name",
  "shortest trajectory size (default ~10 frames)",
  "pom prior",
  "min prob",
  "max prob"
};

void print_help(char *program) {
  printf("Usage: %s [OPTIONS] <data_file>\n", program);
  printf("  where OPTIONS are:\n");
  int index = 0;
  while (long_options[index].name != 0) {
    printf("    ");
    if (long_options[index].val != 0)
      printf("-%c", char(long_options[index].val));
    printf("\t--%s  \t%s\n", long_options[index].name, explanation[index]);
    index++;
  }
}


int main(int argc, char **argv)
{

  // src and sink have a small cost to avoid un-consecutive small segments
  float ss_cost_prob = 0.5-0.0001;

  float MIN_OCCUR_PROB = 1e-6 - 1e-7;
  float MAX_OCCUR_PROB = 1 - MIN_OCCUR_PROB;

  char c;
  const char *config_file_name = NULL;
  const char *output_file_name = "ksp-out.dat";
  size_t buffer_size = 4096;
  char *buffer = new char[buffer_size];

  int first_frame         = 0;
  int last_frame          = 0;
  int grid_width          = 0;
  int grid_height         = 0;
  int grid_size           = 0;
  //int nbr_ort             = 0;
  int nbr_frames          = 0;
  int neighborhood_size   = 0;
  unsigned int nbr_nodes  = 0;
  int depth               = DEFAULT_DEPTH;
  int depth_ort           = 1;
  int max_traj            = DEFAULT_MAX_TRAJ;
  int nbr_ort             = 1;
  char *input_format      = NULL;
  float *input_data       = NULL;
  std::vector<int> access_points;
  double MAX_PATH_LENGTH  = 0;
  double pom_prior 		  = 0.01;
  int nbr_ort_L0 		  = 1;


  // read command line parameters
  while (1) {
    int option_index = 0;

    c = getopt_long (argc, argv, "h:o:s:p:l:u:", long_options, &option_index);
    if (c == -1)
      break;
    switch (c) {
    case 0:
      switch (option_index) {
      default:
        printf("Unrecognized option.\n");
        return 0; //exit(0);
      }

      printf("option %s", long_options[option_index].name);
      if (optarg)
        printf(" with arg %s", optarg);
      printf("\n");
      break;
    case 'h':
      print_help(argv[0]);
      break;
    case 'o':
      output_file_name = optarg;
      break;
    case 's':
      MAX_PATH_LENGTH = -log((1-pom_prior) / pom_prior) * atoi(optarg); // -4.5 ~= -log( 0.99 / (1-0.99) )
	  break;
	  // xinchao added this option to specify the
    case 'p':
      pom_prior = atof(optarg);
      break;
    case 'l':
    	MIN_OCCUR_PROB = atof(optarg);
      break;
    case 'u':
    	MAX_OCCUR_PROB = atof(optarg);
        break;
    default:
      printf("?? getopt returned character code 0%o ??\n", c);
    }
  }

  if (optind < argc) {
    config_file_name = argv[optind++];
    if (optind < argc) {
      printf("Unknown options: ");
      while (optind < argc)
        printf("%s ", argv[optind++]);
      printf("\nThey will be ignored\n");
    }
  }

  if (!config_file_name) {
    printf("Error: no input file specified.\n");
    print_help(argv[0]);
    return 0;
  }


  // open config file
  FILE *config_file = fopen(config_file_name, "r");
  if (!config_file) {
    printf("Error: unable to open configuration file '%s'.\n", config_file_name);
    return 1;
  }

  int res;
  char *dummy_file_name = NULL;
  char *init_file_tracklet = NULL;

  do {
    res = getline(&buffer, &buffer_size, config_file);
    if (res > 0) {
      char *command = strtok(buffer, " ");
      if (command[0] != '#' && command[0] != '\n') { // ignore comments and empty lines

        if (strcmp(command, "GRID") == 0) {
          grid_width = atoi(strtok(NULL, " "));
          grid_height = atoi(strtok(NULL, " "));

        }
        else if (strcmp(command, "FRAMES") == 0) {
          first_frame = atoi(strtok(NULL, " "));
          last_frame  = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "ACCESS_POINTS") == 0) {
          char *ap = strtok(NULL, " ");
          char *cell = strtok(ap, ",");
          while (cell) {
            access_points.push_back(atoi(cell));
            cell = strtok(NULL, ",");
          }
        }
        else if (strcmp(command, "DEPTH") == 0) {
          depth = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "DEPTH_ORT") == 0) {
          depth_ort = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "MAX_TRAJ") == 0) {
          max_traj = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "NBR_ORT") == 0) {
          nbr_ort = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "NBR_ORT_L0") == 0){
          nbr_ort_L0 = atoi(strtok(NULL, " "));
        }
        else if (strcmp(command, "INPUT_FORMAT") == 0) {
          char *inf = strtok(NULL, " \n");
          input_format = new char[strlen(inf) + 1];
          strcpy(input_format, inf);
        }
        else if (strcmp(command, "SS_COST") == 0) {
          ss_cost_prob = atof(strtok(NULL, " "));
		  }
        /*
        else if (strcmp(command, "Init_Path_FILE_L0") == 0) {
		  char *inf = strtok(NULL, " \n");
          dummy_file_name = new char[strlen(inf) + 1];
		  strcpy(dummy_file_name, inf);
		  init_file_tracklet = dummy_file_name;
		}
		*/
        else {
          printf("Unknown command '%s' in configuration file '%s'.\n", command,
                 config_file_name);
          return 1;
        }
      }
    }
  } while (res >= 0);
  fclose(config_file);

  nbr_frames = last_frame - first_frame + 1;
  if (nbr_frames <= 0) {
    printf("Error: No frame is going to be processed.\n");
    return 1;
  }
  neighborhood_size = depth * 2 + 1;
  grid_size = grid_width * grid_height * nbr_ort;
  nbr_nodes = grid_size * nbr_frames;


  // for computing the tracklets -- assign each location as a source/sink
  if (int(access_points.size()) == 1 && access_points[0] == -1)
  {
	  access_points.clear();
	  for (int tmp_i=0;tmp_i<grid_width*grid_height;tmp_i++){
		  access_points.push_back(tmp_i);
	  }
  }




  // print information message
  printf("Input file: '%s'\n", config_file_name);
  printf("===\n");
  printf("Grid: %dx%d\n", grid_width, grid_height);
  printf("%d frames: %d - %d\n", nbr_frames, first_frame, last_frame);
  printf("Depth: %d\n", depth);
  printf("Maximum number of trajectories: %d\n", max_traj);
  printf("%d access point(s)\n", int(access_points.size()));
  printf("Input files: '%s'\n", input_format);
  printf("Output file: '%s'\n===\n\n", output_file_name);
  printf("Nbr of Ort: %d\n", nbr_ort);
  printf("MAX_PATH_LENGTH: %f\n", MAX_PATH_LENGTH);
  printf("pom_prior: %f\n", pom_prior);
  printf("ss_cost: %f\n", ss_cost_prob);


  // reading input files
  printf("Reading input files...");
  fflush(stdout);
  input_data = new float[nbr_nodes];
  float *frame_data = input_data;

  int *	abs_temp_ind = new int[nbr_nodes];
  int * ort_ind = new int[nbr_nodes];
  int * grid_ind = new int[nbr_nodes];
  //FILE * frame_file = NULL;

  // xinchao added the following pointer stuff
  //int frame, ort_ind, grid_ind;
  for (int f=first_frame; f<=last_frame; f++) {
    sprintf(buffer, input_format, f);
    FILE * frame_file = fopen(buffer, "r");
    if (!frame_file) {
      printf("Error: unable to open input file '%s'\n", buffer);
      return 1;
    }
    for (int i=0; i<grid_size; i++) {
      //if (fscanf(frame_file, "%d %f\n", &frame, frame_data + i) != 2) {
          //if (fscanf(frame_file, "%d %d %d %f\n", abs_temp_ind++, &ort_ind, &grid_ind, frame_data + i) != 4) {
		  if (fscanf(frame_file, "%d %d %d %f\n", abs_temp_ind+i, ort_ind+i, grid_ind+i, frame_data+i) != 4) {
        printf("Error while reading input file '%s', position %d\n", buffer, i);
        return 1;
      }
        //std::cout << " frame " << f << " grid size " << i << std::endl;
    }
    fclose(frame_file);
    frame_data += grid_size;
  }
  printf("\t\t\t[ok]\n");

  ///////////////////////// non-maxima suppression //////////////////////////////
  float *input_data_supp = new float[grid_width * grid_height * nbr_frames];
  int * max_data_map = new int[grid_width * grid_height * nbr_frames];
  float tmp_max;
  int tmp_max_o;
  for (int i=0;i<grid_width * grid_height * nbr_frames;i++){
	  tmp_max = -1.0;
	  for (int o=0;o<nbr_ort;o++){
		  if (tmp_max < input_data[i*nbr_ort+o]){
			  tmp_max_o = o;
			  tmp_max = input_data[i*nbr_ort+o];
		  }
	  }
	  max_data_map[i] = tmp_max_o;
	  input_data_supp[i] = tmp_max;
  }


  // taking the log of probabilities
  float ss_cost_prob_log;
  if (ss_cost_prob > 1.0){
	  ss_cost_prob_log = -log(MIN_OCCUR_PROB / MAX_OCCUR_PROB) * ss_cost_prob;
  }else{
	  ss_cost_prob_log = -log(ss_cost_prob / (1-ss_cost_prob) );
  }


  float proba;
  std::cout << " min_prob is " << MIN_OCCUR_PROB << std::endl;
  std::cout << " max_prob is " << MAX_OCCUR_PROB << std::endl;
  std::cout << " ss_cost_prob_log is " << ss_cost_prob_log << std::endl;

  printf("Taking the log of probabilities...");
  fflush(stdout);
  for ( unsigned int i = 0; i < nbr_nodes; i++ ) {
    proba = input_data[i];
	//std::cout << " proba is " << proba ;
    if ( proba < MIN_OCCUR_PROB ) proba = MIN_OCCUR_PROB;
    else if ( proba > MAX_OCCUR_PROB ) proba = MAX_OCCUR_PROB;

    input_data[i] = -log( proba / (1 - proba) );
    //std::cout << " input_data[i]  " << input_data[i] << std::endl;
  }
  printf("\t[ok]\n");


  // taking the log of probabilities on ground grids
  printf("Taking the log of probabilities on suppressed nodes...");
  fflush(stdout);
  for ( unsigned int i = 0; i < grid_width * grid_height * nbr_frames; i++ ) {
    proba = input_data_supp[i];
    if ( proba < MIN_OCCUR_PROB ) proba = MIN_OCCUR_PROB;
    else if ( proba > MAX_OCCUR_PROB ) proba = MAX_OCCUR_PROB;

    input_data_supp[i] = -log( proba / (1 - proba) );
    //std::cout << " input_data[i]  " << input_data_supp[i] << std::endl;
  }
  printf("\t[ok]\n");



  ///////////////////////// constructing the graph ///////////////////////////
  printf("Constructing the graph...");
  fflush(stdout);
  KShorthestPathGraph ksp_graph(input_data_supp,
                                grid_width,
                                grid_height,
                                nbr_frames,
                                neighborhood_size,
                                access_points,
                                ss_cost_prob_log);
  printf("\t\t[ok]\n");



  // running the K-Shorthest node-disjoint paths algorithm
  printf("Running optimization...");
  fflush(stdout);
  unsigned char *labeled_objects = (unsigned char*)calloc(ksp_graph.GetNoOfVertices(),
                                                          sizeof(unsigned char));

  std::cout <<  std::endl << " in main, the number of vert is " << ksp_graph.GetNoOfVertices() << " ";

  int nbr_paths = KShorthestPathComputer::ComputeKShorthestNodeDisjointPaths(ksp_graph,
                                                                             max_traj,
                                                                             MAX_PATH_LENGTH,
                                                                             labeled_objects);
  printf("\t\t\t[ok]\n");
  printf("\nFound K = %d shortest paths.\n", nbr_paths);


  // saving results
  printf("\nSaving results to %s", output_file_name);
  fflush(stdout);

  FILE *output_file = fopen(output_file_name, "w");

  //std::cout << "sizeof(output_file_name) is " << sizeof(output_file_name) << std::endl;
  //std::cout << " sizeof(output_file_name) is " <<sizeof(output_file_name) << std::endl;
  //for (int i=0;i<sizeof(output_file_name);i++) std::cout << output_file_name[i] << std::endl;
  char output_file_name_dp [255];
  char output_file_name_POM [255];
  char output_file_name_loc [255];
  int dummy_i=0; int fname_length = 0;
  while(output_file_name[dummy_i] != '\0'){
	  output_file_name_dp[dummy_i] = output_file_name[dummy_i];
	  output_file_name_POM[dummy_i] = output_file_name[dummy_i];
	  output_file_name_loc[dummy_i] = output_file_name[dummy_i];
	  dummy_i++;
  }
  fname_length = dummy_i;
  output_file_name_dp[fname_length]='.';
  output_file_name_dp[fname_length+1]='d';
  output_file_name_dp[fname_length+2]='p';
  output_file_name_dp[fname_length+3]='\0';

  output_file_name_POM[fname_length]='.';
  output_file_name_POM[fname_length+1]='p';
  output_file_name_POM[fname_length+2]='o';
  output_file_name_POM[fname_length+3]='m';
  output_file_name_POM[fname_length+4]='\0';

  output_file_name_loc[fname_length]='.';
  output_file_name_loc[fname_length+1]='l';
  output_file_name_loc[fname_length+2]='o';
  output_file_name_loc[fname_length+3]='c';
  output_file_name_loc[fname_length+4]='\0';


  FILE *output_file2 = fopen(output_file_name_dp, "w");
  FILE *output_file_loc = fopen(output_file_name_loc, "w");
  if (!output_file) {
    printf("Error: unable to open file '%s' for writing.\n", output_file_name);
    return 1;
  }
  if (!output_file2) {
    printf("Error: unable to open file '%s' for writing.\n", output_file_name_dp);
    return 1;
  }
  if (!output_file_loc) {
    printf("Error: unable to open file '%s' for writing.\n", output_file_name_loc);
    return 1;
  }
  fprintf(output_file, "%d\n", nbr_paths);
  fprintf(output_file2, "%d\n", nbr_paths);
  fprintf(output_file_loc, "%d\n", nbr_paths);

  int *positions = new int[nbr_paths];
  int relative_temp_ind, tmp_spt_linear_ind;
  unsigned char *write_ptr = labeled_objects;
  //write_ptr += 2*grid_width*grid_height*nbr_frames;
  for (int f=first_frame; f<=last_frame; f++) {
    for (int i=0; i<nbr_paths; i++) positions[i] = -1;
    for (int i=0; i<grid_size/nbr_ort; i++) {
      if (write_ptr[i]) {
    	  positions[write_ptr[i] - 1] = i;
      }

    }
    fprintf(output_file, "%d\t", f);
    fprintf(output_file2, "%d\t", f);
    fprintf(output_file_loc, "%d\t", f);
    //for (int i=0; i<nbr_paths; i++) std::cout << positions[i] << std::endl;
    for (int i=0; i<nbr_paths; i++) {
    	tmp_spt_linear_ind = (f-first_frame)*grid_size/nbr_ort + positions[i];
    	if (positions[i] >= 0){
    		relative_temp_ind = positions[i] * nbr_ort + max_data_map[tmp_spt_linear_ind];
    		fprintf(output_file, "%d\t", abs_temp_ind[relative_temp_ind]);
    		fprintf(output_file2, "%d\t", relative_temp_ind);

    		int tmp_x = (relative_temp_ind/nbr_ort) % (grid_width);
		int tmp_y = (relative_temp_ind/nbr_ort) / (grid_width);
  //              cerr << relative_temp_ind << " " << relative_temp_ind / nbr_ort << " " << tmp_x << " " << tmp_y << endl;
    		fprintf(output_file_loc, "%d^%d\t", tmp_x, tmp_y);


    	}else{
			fprintf(output_file, "%d\t", positions[i]);
			fprintf(output_file2, "%d\t", positions[i]);
			fprintf(output_file_loc, "%d^%d\t", positions[i],positions[i]);
    	}
    }
    fprintf(output_file, "\n");
    fprintf(output_file2, "\n");
    fprintf(output_file_loc, "\n");
    //if (f<last_frame)
    write_ptr += grid_size/nbr_ort;
  }
  fclose(output_file);
  fclose(output_file2);
  fclose(output_file_loc);

  delete [] positions;
  printf("\t\t\t[ok]\n");

  std::cout << " now ksp_graph.GetNoOfVertices() is " << ksp_graph.GetNoOfVertices() << std::endl;
  ///////////////////////////////////









  // print out those templates to be shown in the POM file
  FILE *output_file_pom = fopen(output_file_name_POM, "w");
  std::vector<int> tmp_hit;
  int tmp_offset = 0;
  for (int f=first_frame; f<=last_frame; f++) {
	  tmp_offset = (f-first_frame) * grid_size;
	  fprintf(output_file_pom, "%d\t", f);
	  tmp_hit.clear();
	  for (int i=0; i<grid_size; i++) {
		  // NOTE here, the threshold is set to be 0!
		  //std::cout << " before input_data[tmp_offset + i] < 0" << std::endl;
		  if (input_data[tmp_offset + i] < 0)
		  {
			  //std::cout << "entered  input_data[tmp_offset + i] < 0" << std::endl;
			  tmp_hit.push_back(i);
		  }
	  }
	  fprintf(output_file_pom, "%d\t", int(tmp_hit.size()));
	  for (int i=0;i<tmp_hit.size();i++)
	  {
		  //std::cout << " before abs_temp_ind[tmp_hit[i]]"<< std::endl;
		  fprintf(output_file_pom, "%d\t", abs_temp_ind[tmp_hit[i]]);
		  //std::cout << " after abs_temp_ind[tmp_hit[i]]" << std::endl;
	  }
	  fprintf(output_file_pom, "\n");

  }
  fclose(output_file_pom);










  // releasing memory
  free(labeled_objects);

  delete [] input_data;
  delete [] buffer;
  if (input_format) delete [] input_format;


  std::cout << "KSP has completed." << std::endl;

  return 0;
}

// Local Variables:
// mode: c++
// compile-command: "make -C ."
// End:
