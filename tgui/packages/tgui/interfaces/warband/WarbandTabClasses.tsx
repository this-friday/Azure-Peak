import { Button, Section, Stack } from 'tgui-core/components';

import { ClassType, WarbandType } from './WarbandTypes';

type ClassesTabProps = {
  selectedWarband: WarbandType | null;
  selectedClass: ClassType | null;
  selectedSubclass: ClassType | null;
  availableClasses: ClassType[];
  filteredSubclasses: ClassType[];
  handleClassSelect: (classe: ClassType) => void;
  handleSubclassSelect: (subclass: ClassType) => void;
  act: (action: string) => void;
  canModify?: boolean;
  slotCounts?: Record<string, number>;
};

export const ClassesTab = ({
  selectedWarband,
  selectedClass,
  selectedSubclass,
  availableClasses,
  filteredSubclasses,
  handleClassSelect,
  handleSubclassSelect,
  act,
  canModify = true,
  slotCounts = {},
}: ClassesTabProps) => {
  const subclassExempt = !!selectedClass?.ignores_uni_class_requirement;
  const classIsFull = (classe: ClassType) =>
    classe.slots >= 0 && (slotCounts[classe.type] ?? 0) >= classe.slots;
  return (
    <Stack vertical fill>
      <Stack row-Reverse style={{ flex: 1 }}>
        <Section 
          title={<span style={{ color: '#7a2525ff' }}>AVAILABLE CLASSES</span>} 
          scrollable 
          fill 
          style={{ flex: 1, minWidth: '5px' }}
        >
          {selectedWarband && availableClasses.length > 0 ? (
            <Stack vertical>
              {availableClasses.map((classe) => {
                const isSelected = selectedClass?.type === classe.type;
                const isFull = !isSelected && classIsFull(classe);
                return (
                  <Button
                    key={classe.type}
                    onClick={() => {
                      if (!canModify || isFull) return;
                      handleClassSelect(classe);
                      act('interaction_sound');
                    }}
                    disabled={!canModify || isFull}
                    style={{
                      backgroundColor: isSelected ? '#7a2525ff' : undefined,
                      whiteSpace: 'normal',
                      textAlign: 'left',
                      opacity: isFull ? 0.5 : 1,
                    }}>
                    <Stack vertical>
                      <span style={{ fontSize: '14px' }}>
                        {classe.name || classe.alt_name}
                        {isFull && <span style={{ fontSize: '11px', color: '#d46060', marginLeft: '8px' }}>(FULL)</span>}
                      </span>
                      <span style={{ fontSize: '12px', color: '#ccc' }}>{classe.desc}</span>
                    </Stack>
                  </Button>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <p style={{ color: '#7a2525ff' }}>NO CLASSES AVAILABLE</p>
            </div>
          )}
        </Section>
        
        <Section 
          title={<span style={{ color: '#7a2525ff' }}>AVAILABLE {(selectedWarband?.subclass_label || 'SUBCLASS').toUpperCase()}ES</span>} 
          scrollable 
          fill 
          style={{ flex: 1 }}
        >
          {selectedWarband?.universal_subclasses_enabled && !subclassExempt && filteredSubclasses.length > 0 ? (
            <Stack vertical>
              {filteredSubclasses.map((subclass) => {
                const isSelected = selectedSubclass?.type === subclass.type;
                const isFull = !isSelected && classIsFull(subclass);
                return (
                  <Button
                    key={subclass.type}
                    onClick={() => {
                      if (!canModify || isFull) return;
                      handleSubclassSelect(subclass);
                      act('interaction_sound');
                    }}
                    disabled={!canModify || isFull}
                    style={{
                      backgroundColor: isSelected ? '#7a2525ff' : undefined,
                      whiteSpace: 'normal',
                      textAlign: 'left',
                      opacity: isFull ? 0.5 : 1,
                    }}>
                    <Stack vertical>
                      <span style={{ fontSize: '14px' }}>
                        {subclass.name || subclass.alt_name}
                        {isFull && <span style={{ fontSize: '11px', color: '#d46060', marginLeft: '8px' }}>(FULL)</span>}
                      </span>
                      <span style={{ fontSize: '12px', color: '#ccc' }}>{subclass.desc}</span>
                    </Stack>
                  </Button>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <p style={{ color: '#7a2525ff' }}>
                {subclassExempt
                  ? `THIS CLASS TAKES NO ${(selectedWarband?.subclass_label || 'SUBCLASS').toUpperCase()}`
                  : selectedWarband?.universal_subclasses_enabled
                  ? `NO ${(selectedWarband.subclass_label || 'SUBCLASS').toUpperCase()}ES AVAILABLE`
                  : 'UNAVAILABLE FOR THIS WARBAND'}
              </p>
            </div>
          )}
        </Section>
      </Stack>
      
      <Section style={{ flex: 0.3 }}>
        <Stack direction="row" justify="center">
          <Button
            onClick={() => {
              if (!canModify) return;
              act('swap_character_slot');
              act('interaction_sound');
            }}
            disabled={!canModify}
            style={{ 
              fontSize: '25px', 
              padding: '25px',
              flex: 1, 
              display: 'flex', 
              marginBottom: '110px',
              justifyContent: 'center', 
              alignItems: 'center',
            }}>
            CHANGE CHARACTER SLOT
          </Button>
          <Button
            onClick={() => {
              if (!canModify) return;
              act('edit_character');
              act('interaction_sound');
            }}
            disabled={!canModify}
            style={{ 
              fontSize: '25px', 
              padding: '25px', 
              flex: 1, 
              display: 'flex',
              marginBottom: '110px',
              justifyContent: 'center', 
              alignItems: 'center',
            }}>
            EDIT APPEARANCE
          </Button>
        </Stack>
      </Section>
    </Stack>
  );
};
